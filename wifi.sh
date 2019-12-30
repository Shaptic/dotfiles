#! /bin/bash

# Turns WiFi on and off depending on the parameter

iface=$(ip link | grep -i '\bw' | awk -F':' '{print $2}')
echo -n "Bringing$iface $1... "
sudo ip link set $iface $1
echo "done."
