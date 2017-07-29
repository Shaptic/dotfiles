#!/bin/bash
echo "`date '+%Y-%m-%d %H:%M'`"
if [[ $BLOCK_BUTTON == '1' ]]; then
  gsimplecal
fi
