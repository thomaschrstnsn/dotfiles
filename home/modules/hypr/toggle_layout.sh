#! /usr/bin/env bash

set -e

CURRENT_LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str')

if [ "$CURRENT_LAYOUT" = "master" ]; then
    NEW_LAYOUT="dwindle"
else
    NEW_LAYOUT="master"
fi

hyprctl keyword general:layout "$NEW_LAYOUT"
notify-send -t 2000 "Layout toggled" "$NEW_LAYOUT"
