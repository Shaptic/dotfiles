#!/bin/bash
MASK=$(xset -q | grep -A 0 'LED' | cut -c59-66)

if [[ "$MASK" == "00000000" ]]; then
  echo "EN"
  echo "EN"
  echo "#2ECC71"

elif [[ "$MASK" == "00001000" ]]; then
  echo "RU"
  echo "RU"
  echo "#EF4836"

else
  echo "??"
fi
