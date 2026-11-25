#! /usr/bin/env bash

set -e

DEVICE=$1
hyprctl switchxkblayout "$1" next

NEW_LAYOUT=$(hyprctl devices -j | jq ".keyboards[] | select(.name == \"$DEVICE\") | .active_keymap")
notify-send "toggled layout to: " "$NEW_LAYOUT"
