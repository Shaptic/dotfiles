#!/bin/bash

ACTIVE_SINK=$(pacmd list-sinks | grep -oP '\* index: (\d+)' | grep -oP '\d+')
echo $(pactl list sinks | grep -P '^\s+Volume:' | \
       head -n $(( $ACTIVE_SINK + 1 )) | \
       tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%
