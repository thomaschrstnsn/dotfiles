#!/bin/sh
curWindowId="$(yabai -m query --windows --window | jq -re ".id")"

case $1 in
'left')
    yabai -m window --display prev || yabai -m window --display last
    ;;
'right')
    yabai -m window --display next || yabai -m window --display first
    ;;
esac

yabai -m window --focus "$curWindowId"
