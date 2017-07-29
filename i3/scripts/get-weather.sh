#!/bin/bash

URL='https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22kirkland%2C%20wa%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
OUT=$(curl -s $URL)
temp=$( echo $OUT | jq '.[] | .results.channel.item.condition | .temp' | sed -s s/\"//g)
state=$(echo $OUT | jq '.[] | .results.channel.item.condition | .text' | sed -s s/\"//g)

STATE="$temp° "
if [[ "$state" == "Sunny" ]]; then
  STATE="$STATE🌞"
  COLOR="#F9BF3B"
fi

echo $STATE
echo $STATE
echo $COLOR
