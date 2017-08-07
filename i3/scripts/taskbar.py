#!/usr/bin/python2
# -*- coding: utf-8 -*-

""" A taskbar manager for i3blocks.

TODO: Better error-handling.
      Celsius support.
      Better location testing.
      Investigate a better weather API for international lookups?
      Support $BLOCK_BUTTON from i3blocks for opening up a full weather page?
"""
import os
import re
import sys
import time

import enum
import collections
import argparse
import requests

import json
from   xml.dom  import minidom
from   datetime import datetime, timedelta

DESCRIPTION = """Creates various blocks for the i3blocks taskbar.

    Pass the mode you wish to use, which must be one of the supported modes:
        - weather
        - location
        - peaks

    Location Mode
    =============
    This mode is _not_ i3blocks compatible, it is only used for determining the
    current approximate coordinates and city based on the current public IP
    address.

    Weather Mode
    ============
    This provides location-aware weather based on IP address geolocation. We
    determine the location just like in Location Mode, via a Google API, unless
    it's provided via `--zipcode` or `--coord` mode. Then, we analyze the
    weather data at the location:

        - The current city, which is used in the "full" output.
        - The current "peak" times -- the sunrise and sunset -- for that date,
          which, on a "clear" day, show special icons around that time period.
        - These are all combined for a unique (icon, color) combination for the
          current weather in that city.

    If you pass `-z` with a zipcode value, we don't perform any coordinate
    lookups, so you can get API-key-less functionality. This means you don't get
    location-aware weather, though.

    NOTE: Only locations in the United States are supported, because the
          AccuWeather API uses postal codes for lookups in the RSS feed.

    Peak Mode
    =========
    Provides a way to directly retrieve sunrise and sunset times from the
    current location.

    API Keys
    ========
    Because we use Google's APIs, there need to be API keys present for the
    calls to work. It's trivial to get one, just go to these links:

        https://developers.google.com/maps/documentation/geocoding/get-api-key
        https://developers.google.com/maps/documentation/geolocation/get-api-key
        https://developers.google.com/maps/documentation/timezone/get-api-key

    and add these to a ".keys" file (with each key on its own line) in the same
    directory as the weather script (by default). This can be changed by passing
    in `--keyfile`. Don't forget to add the file to your .gitignore (if
    applicable) to be safe :)

    NOTE: This isn't necessary in `--zipcode` mode.

    Usage
    =====
    In your .i3blocks.conf file, add this block for weather support (with
    whatever interval you want, but be wary of API rate-limiting):

        [weather]
        command=taskbar.py weather
        interval=360
"""
        # raise NotImplemented
        # - The current weather, using the AccuWeather RSS API, which
        #   unfortunately does not provide the "real feel" data. Try passing the
        #   experimental `--real-feel` flag. This _must be_ combined with
        #   `--weather-url`, because dynamically determining the AccuWeather
        #   "real" path (the one you view in the browser) is not supported yet.

# https://developers.google.com/maps/documentation/geolocation/
# https://developers.google.com/maps/documentation/geocoding/
# https://developers.google.com/maps/documentation/timezone/
# https://sunrise-sunset.org/api
IP_URL = "https://www.googleapis.com/geolocation/v1/geolocate?key="
LOC_URL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=%s&key="
SUN_URL = "https://api.sunrise-sunset.org/json?lat=%f&lng=%f&formatted=1"
TZ_URL = "https://maps.googleapis.com/maps/api/timezone/json?" + \
         "location=%f,%f&timestamp=%d&key="

TMP_URL = "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=%d&locCode=%s"
KEYPATH = os.path.join(os.path.dirname(sys.argv[0]), ".keys")
API_KEYS = tuple()

BlockOutput = collections.namedtuple("i3BlockOutput", "full short color")
WeatherBlock = BlockOutput(u"%d°%s (%s)",   # temperature, icon, city
                           u"%d°%s",        # just temperature + icon
                           "%s")            # color based on weather
ICONS = {
    "Clear":        (u"🌙", "#67809F"),
    "DayClear":     (u"☀",  "#22A7F0"),
    "Sunny":        (u"☀",  "#F9BF3B"),
    "Partly Sunny": (u"🌤", "#F5D76E"),
    "Cloudy":       (u"🌥", "#6C7A89"),
    "Partly Cloudy":(u"🌥", "#67809F"),
    "Sunrise":      (u"🌅", "#E26A6A"),
    "Sunset":       (u"🌅", "#E26A6A"),
    "default":      (u"",   "#C5EFF7"),
}


class SimpleWeather(object):
    """ Determines location and weather from only a zipcode.

    :zipcode        a US zip code value
    :time[=None]    a `datetime` object at which to determine the weather,
                    defaulting to the current time
    """

    def __init__(self, zipcode, time=None):
        self._now = datetime.now() if not time else time
        self.zip = zipcode
        results = get_weather(self.zip, faren=True, parse_city=True)
        if not results:
            raise ValueError("Failed to find weather data for location: " +\
                             repr(self.zip))

        self.temp, self.desc, self.city = results
        sunrise = self._now.replace(hour=6, minute=30)
        sunset  = self._now.replace(hour=9)
        self.peaks = (
            (sunrise - timedelta(hours=1), sunrise),
            (sunset  - timedelta(hours=1), sunset))

        if self.desc not in self.WEATHER:
            self.icon, self.color = ICONS["default"]
        else:
            self.icon, self.color = self.WEATHER[self.desc](self, self.desc)

    def on_clear(self, desc):
        """ Handles "Clear" weather, which changes based on time of day.
        """
        sunrise, sunset = self.peaks
        if self._now > sunset[1] and self._now < sunrise[0]:
            return ICONS[desc]      # night time

        return ICONS["DayClear"]

    def on_sunset(self):
        if self.is_sunrise(): return ICONS["Sunrise"]
        if self.is_sunset():  return ICONS["Sunset"]

    def on_sunny(self, desc):
        retval = self.on_sunset()
        return retval if retval else ICONS["Sunny"]

    def on_simple(self, desc):
        if desc not in ICONS: return ICONS["default"]
        return ICONS[desc]

    def is_sunrise(self):
        return self._now >= self.peaks[0][0] and self._now <= self.peaks[0][1]

    def is_sunset(self):
        return self._now >= self.peaks[1][0] and self._now <= self.peaks[1][1]

    @property
    def full(self):
        return (WeatherBlock.full % (self.temp,
            self.icon if self.icon else (u" [%s]" % self.desc),
            self.city)).encode("utf-8")

    @property
    def short(self):
        return (WeatherBlock.short % (self.temp, self.icon)).encode("utf-8")

    @property
    def block(self):
        return "\n".join((self.full, self.short, self.color))

    WEATHER = {
        "Clear":        on_clear,
        "Sunny":        on_sunny,
        "Partly Sunny": on_simple,
        "Partly Cloudy":on_simple,
        "Cloudy":       on_simple,
        "default":      on_simple,
    }


class SmartWeather(SimpleWeather):
    """ Describes the complete weather state for a location.

    The data that we determine is suitable for outputting an i3block, which is
    a 3-tuple of (short description, full description, color).

    :location           a 2-tuple of latitude and longitude coordinates
    :time[=None]        a `datetime` object at which to determine the weather,
                        defaulting to the current time
    """

    def __init__(self, location, time=None):
        self._now = datetime.now() if not time else time

        self.city, self.zip = get_city(location)
        self.temp, self.desc, _ = get_weather(self.zip, faren=True)
        self.peaks = get_peak_times(location)

        if self.desc not in self.WEATHER:
            self.icon, self.color = ICONS["default"]
        else:
            self.icon, self.color = self.WEATHER[self.desc](self, self.desc)


def get_peak_times(location):
    """ Retrieves sunrise and sunset times for certain coordinates.

    We create a range of times for each peak, where the peak is considered to
    take place about half an hour before and after the peak time.
    """

    response = requests.get(SUN_URL % location)
    times = response.json()

    sunrise = times["results"]["sunrise"]
    sunset  = times["results"]["sunset"]
    sunrise = datetime.strptime(sunrise, "%I:%M:%S %p")
    sunset  = datetime.strptime(sunset,  "%I:%M:%S %p")

    # Now, determine our timezone so we can get proper offsets, because the
    # times are originally in UTC.
    response = requests.get(TZ_URL % (location[0], location[1], int(time.time())))
    timezone = response.json()

    offset   = timedelta(seconds=timezone["rawOffset"])
    offset  += timedelta(seconds=timezone["dstOffset"])
    sunrise += offset
    sunset  += offset
    return (
        (sunrise - timedelta(minutes=30),
         sunrise + timedelta(minutes=30)),
        (sunset  - timedelta(minutes=30),
         sunset  + timedelta(minutes=30)),
    )

def get_location():
    """ Retrieves approximate location via the Google API using your IP address.
    """
    args = json.dumps({ "considerIp": "true" })
    response = requests.post(IP_URL, data=args,
                             headers={"Content-Type": "application/json"})

    if response.status_code != 200:
        return (47.68, -122.24)     # default location, somewhere in WA

    j = response.json()
    return tuple(j["location"].values())

def get_city(location):
    """ Retrieves the approximate city at some coordinates.
    """
    response = requests.get(LOC_URL % ','.join([str(x) for x in location]))
    j = response.json()

    city, state, country, postal = "", "", "", 0
    for row in j["results"]:
        for item in row["address_components"]:
            types = item["types"]
            if not state and "administrative_area_level_1" in types:
                state = item["short_name"]
            if not city and "locality" in types:
                city = item["long_name"]
            if not country and "country" in types:
                country = item["short_name"]
            if not postal and "postal_code" in types:
                postal = item["long_name"]

    if not any((city, state, country)):
        return False

    if city: city += ", "   # is there a world where city exists and
                            # state / country don't? don't care to find out...
    if state: city += state
    elif country: city += country

    return city, postal

def get_weather(zip_code, faren=True, parse_city=False):
    """ Retrieves the current weather (temp, description) at a zip code.
    """
    response = requests.get(TMP_URL % (int(not faren), zip_code))
    xml = minidom.parseString(response.text)
    items = xml.getElementsByTagName("item")
    if not items: return None
    current = items[0]

    title = current.getElementsByTagName("title")[0].childNodes[0].data
    matches = re.match("Currently: (.*): (\d+)%s" % ("F" if faren else "C"),
                       title)
    if not matches: return None
    temp, status = int(matches.group(2)), matches.group(1)

    city = ""
    if parse_city:
        desc = current.getElementsByTagName("description")[0].childNodes[0].data
        matches = re.match("Currently in (.*): (\d+)", desc)
        city = matches.group(1)

    return temp, status, city

def main():
    MODES = ("weather", "peaks", "location", "test-i3")
    parser = argparse.ArgumentParser(description=DESCRIPTION,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("mode", help="one of " + repr(MODES) + " indicating "
                                     "the block you wish to generate (or task "
                                     "you wish to perform)")
    parser.add_argument("-c", "--coords", metavar=("lat","long"), nargs=2,
                        type=float,
                        help="performs actions for the specified [mode] at the "
                             "specified location")
    parser.add_argument("-f", "--keyfile", metavar="path", default=KEYPATH,
                        help="path pointing to your Google API keys")
    parser.add_argument("-z", "--zipcode", metavar="code", type=int,
                        help="skips all coordinate lookups and does the most "
                             "that's possible with a zipcode")
    args = parser.parse_args()

    if args.mode not in MODES:
        print "Valid modes are: %s" % ','.join(MODES)
        sys.exit(1)

    # We don't need API key validation in zipcode mode.
    if not args.zipcode:
        global API_KEYS, IP_URL, LOC_URL, TZ_URL
        with open(args.keyfile, "r") as f:
            API_KEYS = tuple(f.read().strip().split())
            if len(API_KEYS) != 3:
                parser.error("API keyfile (at %s) must have 2 keys, one per " \
                             "line for the geolocate, geocode, and timezone " \
                             "APIs, respectively." % args.keyfile)

            IP_URL  += API_KEYS[0]
            LOC_URL += API_KEYS[1]
            TZ_URL  += API_KEYS[2]

    if args.zipcode:
        loc = args.zipcode
    else:
        loc = get_location() if not args.coords else tuple(args.coords)

    if args.zipcode and args.mode != "weather":
        parser.error("--zipcode should only be used in weather mode")

    if args.mode == "weather":
        w = SimpleWeather(args.zipcode) if args.zipcode else SmartWeather(loc)
        print w.block

    elif args.mode == "location":
        print loc
        print "%s | %s" % get_city(loc)

    elif args.mode == "peaks":
        delta = timedelta(minutes=30)
        city, _ = get_city(loc)
        sunrise, sunset = get_peak_times(loc)
        sunrise = sunrise[0] + delta
        sunset  = sunset[0]  + delta
        print "In", city, "the..."
        print "  sunrise is at", sunrise.time().strftime("%I:%M:%S %p")
        print "  sunset  is at", sunset.time().strftime( "%I:%M:%S %p")

    elif args.mode == "test-i3":
        print "long test"
        print "test"
        print "#FFFFFF"

if __name__ == '__main__':
    main()
