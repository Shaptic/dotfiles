#!/bin/bash
case $1 in
	start|reload|restart|force-reload)
		sudo echo -n 190 > /sys/devices/platform/i8042/serio1/serio2/sensitivity
		;;
	status)
		echo -n "The sensitivity is set to: "
		cat /sys/devices/platform/i8042/serio1/serio2/sensitivity
		;;
	*)
		echo "Just run it?"
		exit 1
		;;
esac
