#!/bin/bash

iface="en0"

status="$(networksetup -getairportpower "$iface")"
status="${status#*: }"

if [ "$status" = "On" ]
then
  sketchybar -m --set wifi icon="睊" icon.padding_right=0 label=""
  networksetup -setairportpower "$iface" off
else
  sketchybar -m --set wifi icon=""
  networksetup -setairportpower "$iface" on
fi
