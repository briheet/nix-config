#!/usr/bin/env bash

WS1=1
WS2=2

CURRENT=$(($(wmctrl -d | grep " \* " | awk '{print $1}') + 1))

if [ $CURRENT -eq $WS1 ]; then
  wmctrl -s $(($(echo $WS2) - 1))
else
  wmctrl -s $(($(echo $WS1) - 1))
fi

exit 0
