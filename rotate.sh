#!/bin/bash
#
# rotate.sh
#
# Rotates modern Linux desktop screen and input devices to match. Handy for
# convertible notebooks. Call this script from panel launchers, keyboard
# shortcuts, or touch gesture bindings (xSwipe, touchegg, etc.).
#
# Using transformation matrix bits taken from:
#   https://wiki.ubuntu.com/X/InputCoordinateTransformation
#

# display from xrandr
#Display='eDP1'
# get automatically
Display=$(xrandr -q | head -2 | grep connected | awk -F ' ' '{print $1}');

# Configure these to match your hardware (names taken from `xinput` output).
Touchpad='TPPS/2 IBM TrackPoint'
Trackpoint='TPPS/2 IBM TrackPoint'
WacomPen='Wacom Pen and multitouch sensor Pen'
WacomFinger='Wacom Pen and multitouch sensor Finger'

if [ -z "$1" ]; then
  echo "Missing orientation."
  echo "Usage: $0 [normal|inverted|left|right]"
  echo
  exit 1
fi

xrandr --output $Display --rotate $1

TRANSFORM='Coordinate Transformation Matrix'
LIBINPUT='libinput Calibration Matrix'

case "$1" in
  normal)
    xinput set-prop "$Touchpad" "$TRANSFORM"     1 0 0 0 1 0 0 0 1
    xinput set-prop "$Trackpoint" "$TRANSFORM"   1 0 0 0 1 0 0 0 1
    xinput set-prop "$WacomPen" "$LIBINPUT"      1 0 0 0 1 0 0 0 1
    xinput set-prop "$WacomFinger" "$LIBINPUT"   1 0 0 0 1 0 0 0 1
    ;;
  inverted)
    xinput set-prop "$Touchpad" "$TRANSFORM"    -1 0 1 0 -1 1 0 0 1
    xinput set-prop "$Trackpoint" "$TRANSFORM"  -1 0 1 0 -1 1 0 0 1
    xinput set-prop "$WacomPen" "$LIBINPUT"     -1 0 1 0 -1 1 0 0 1
    xinput set-prop "$WacomFinger" "$LIBINPUT"  -1 0 1 0 -1 1 0 0 1
    ;;
  left)
    xinput set-prop "$Touchpad" "$TRANSFORM"     0 -1 1 1 0 0 0 0 1
    xinput set-prop "$Trackpoint" "$TRANSFORM"   0 -1 1 1 0 0 0 0 1
    xinput set-prop "$WacomPen" "$LIBINPUT"      0 -1 1 1 0 0 0 0 1
    xinput set-prop "$WacomFinger" "$LIBINPUT"   0 -1 1 1 0 0 0 0 1
    ;;
  right)
    xinput set-prop "$Touchpad" "$TRANSFORM"     0 1 0 -1 0 1 0 0 1
    xinput set-prop "$Trackpoint" "$TRANSFORM"   0 1 0 -1 0 1 0 0 1
    xinput set-prop "$WacomPen" "$LIBINPUT"      0 1 0 -1 0 1 0 0 1
    xinput set-prop "$WacomFinger" "$LIBINPUT"   0 1 0 -1 0 1 0 0 1
    ;;
esac
