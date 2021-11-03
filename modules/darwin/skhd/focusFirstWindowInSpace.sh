#!/bin/sh

yabai -m query --spaces --space "$1" | jq -r '.windows[0] // empty' | xargs yabai -m window --focus