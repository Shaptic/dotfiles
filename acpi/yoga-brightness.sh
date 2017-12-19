#!/bin/sh

BR_DIR="/sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/"

test -d "$BR_DIR" || exit 0

MIN=0
MAX=$(cat "$BR_DIR/max_brightness")
VAL=$(cat "$BR_DIR/brightness")

if [ "$1" = down ]; then
    VAL=$((VAL-71))
else
    VAL=$((VAL+71))
fi

if [ "$VAL" -lt $MIN ]; then
    VAL=$MIN
elif [ "$VAL" -gt $MAX ]; then
    VAL=$MAX
fi

PERCENT=`echo "$VAL / $MAX" | bc -l`

export XAUTHORITY=/home/m0bius/.Xauthority
export DISPLAY=:0.0

echo "xrandr --output eDP1 --brightness $PERCENT" > /tmp/yoga-brightness.log
xrandr --output eDP1 --brightness $PERCENT

echo $VAL > "$BR_DIR/brightness"
