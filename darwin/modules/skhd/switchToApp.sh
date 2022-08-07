#! /usr/bin/env bash

currentWindow=$(yabai -m query --windows --window)
currentWindowId=$(echo "$currentWindow" | jq -r '.id')

windowsForApp=$(yabai -m query --windows | jq -r "sort_by(.id) | .[] | select(.id != $currentWindowId) | select(.app == \"$1\")")

currentDisplay=$(echo "$currentWindow" | jq -r ".display")
currentSpace=$(echo "$currentWindow" | jq -r ".space")

# echo windows 
# echo $windowsForApp | jq
# echo space $currentSpace
# echo display $currentDisplay

windowOnCurrentSpace=$(echo "$windowsForApp" | jq -r "select(.space == $currentSpace and .display == $currentDisplay) | .id" | head -n 1)
# echo window on current space: $windowOnCurrentSpace
if [ -n "$windowOnCurrentSpace" ]
then
    yabai -m window --focus "$windowOnCurrentSpace" && exit
fi

windowOnCurrentDisplay=$(echo "$windowsForApp" | jq -r "select(.display == $currentDisplay and .space != $currentSpace) | .id" | head -n 1)
# echo window on current display: $windowOnCurrentDisplay
if [ -n "$windowOnCurrentDisplay" ]
then
    yabai -m window --focus "$windowOnCurrentDisplay" && exit
fi

windowAnywhere=$(echo "$windowsForApp" | jq -r "select(.display != $currentDisplay).id" | head -n 1)
# echo window anywhere: $windowAnywhere
if [ -n "$windowAnywhere" ]
then
    yabai -m window --focus "$windowAnywhere" && exit
fi
