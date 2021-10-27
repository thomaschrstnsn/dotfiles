#!/bin/sh

CurrentlyFocusedWindow=$(yabai -m query --windows --window | jq -re ".")

CurrentlyFocusedWindowID=$(echo $CurrentlyFocusedWindow | jq -re ".id")

CurrentlyFocusedDisplay=$(echo $CurrentlyFocusedWindow | jq -re ".display")

CurrentlyFocusedSpace=$(echo $CurrentlyFocusedWindow | jq -re ".space")

EmptySpace=$(yabai -m query --spaces | jq --argjson display $CurrentlyFocusedDisplay -r 'first(.[] | select(.windows == [] and .display == $display).index)')

if [ -z "$EmptySpace" ]
then
    echo "no empty space found"
else
    $(yabai -m window --space $EmptySpace)
    $(yabai -m window --focus "$CurrentlyFocusedWindowID")
fi