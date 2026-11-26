#!/bin/sh

# e.g. "Wed 14 Oct  10:42:07"
sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M:%S')"
