#! /usr/bin/env bash

currentWindow=$(yabai -m query --windows --window)
currentApp=$(echo "$currentWindow" | jq -r '.app')
if [ -z "$currentApp" ]
then
    exit
fi
currentWindowId=$(echo "$currentWindow" | jq -r '.id')

# multiply ids lower than this to cycle
windowsForApp=$(yabai -m query --windows | jq -r "sort_by(if .id <= $currentWindowId then .id * 100 else .id end) | .[] | select(.id != $currentWindowId) | select(.app == \"$currentApp\")")

window=$(echo "$windowsForApp" | jq -r ".id" | head -n 1)
yabai -m window --focus "$window" && exit
