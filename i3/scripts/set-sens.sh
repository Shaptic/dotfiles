#! /bin/sh
if [ $? -ne 1 ]; then
  sens=220
else
  sens=$1
fi

echo "Setting sensitivity to $sens."
echo -n $sens | sudo tee /sys/devices/platform/i8042/serio1/serio2/sensitivity
