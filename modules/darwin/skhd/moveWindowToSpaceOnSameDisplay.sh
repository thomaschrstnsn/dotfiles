#!/bin/sh

CurrentlyFocusedWindow=$(yabai -m query --windows --window | jq -re ".")

CurrentlyFocusedWindowID=$(echo $CurrentlyFocusedWindow | jq -re ".id")

CurrentlyFocusedDisplay=$(echo $CurrentlyFocusedWindow | jq -re ".display")

CurrentlyFocusedSpace=$(echo $CurrentlyFocusedWindow | jq -re ".space")

case $1 in
'prev')
    NextSpace=$((CurrentlyFocusedSpace-1))
    ;;
'next')
    NextSpace=$((CurrentlyFocusedSpace+1))
    ;;
esac


NextSpaceDisplay=$(yabai -m query --spaces --space $NextSpace | jq -r ".display")

if [[ $NextSpaceDisplay == *$CurrentlyFocusedDisplay* ]]; then
    $(yabai -m window --space $NextSpace)
    $(yabai -m window --focus "$CurrentlyFocusedWindowID")
fi
