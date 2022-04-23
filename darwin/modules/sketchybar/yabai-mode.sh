#!/bin/bash

yabai_mode=$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].type')

case "$yabai_mode" in
    bsp)
    sketchybar -m --set yabai_mode icon=""
    ;;
    stack)
    sketchybar -m --set yabai_mode icon=""
    ;;
    float)
    sketchybar -m --set yabai_mode icon=""
    ;;
esac