#!/bin/bash

ID=$(xinput | grep -i "Finger" | grep -Pio 'id=\d+' | awk -F= '{print $2}')
xinput map-to-output $ID eDP1
