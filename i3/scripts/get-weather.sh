#!/bin/bash
if (( $# == 1 )); then
  LOC=$1
else
  LOC=98033
fi

URL="http://rss.accuweather.com/rss/liveweather_rss.asp?metric=0&locCode=$LOC"
OUT=$(curl -s $URL | grep "Currently in")
CITY=$(echo $OUT | grep -oP "Currently in (.*):" | sed -s 's/Currently in '// | sed -s s/://)
OUT=$(echo $OUT | awk -F: '{print $2}')

temp=$(echo $OUT | awk '{print $1}')
weather=$(echo $OUT | sed -s 's/.*and //' | sed -s 's/\s//g')

OUTPUT="$temp°"

# Clear: Sun during day, Moon at night.
if [[ "$weather" == "Clear" ]]; then
  H=$(date +%H)
  if (($H >= 21)); then
    OUTPUT="$OUTPUT🌙"
    COLOR="#67809F"
  else
    OUTPUT="$OUTPUT🌞"
    COLOR="#F9BF3B"
  fi

elif [[ "$weather" == "Sunny" ]]; then
  OUTPUT="$OUTPUT🌞"
  COLOR="#F9BF3B"

else
  OUTPUT="$OUTPUT[$weather]"
  COLOR="#C5EFF7"
fi

if [[ $BLOCK_BUTTON == '1' ]]; then
  firefox 'https://www.accuweather.com/en/us/kirkland-wa/98033/weather-forecast/341298'
fi

echo "${OUTPUT} (${CITY})"
echo $OUTPUT
echo $COLOR
