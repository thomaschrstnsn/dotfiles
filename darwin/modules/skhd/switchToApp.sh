#! /usr/bin/env bash

currentWindow=$(yabai -m query --windows --window)
currentWindowId=$(echo "$currentWindow" | jq -r '.id')

windowsForApp=$(yabai -m query --windows | jq -r "sort_by(.id) | .[] | select(.app == \"$1\")")

if [ -z "$windowsForApp" ]
then
    echo "$1" has no windows, opening
    open -a "$2"
    exit
fi

windowsForApp=$(yabai -m query --windows | jq -r "sort_by(.id) | .[] | select(.id != $currentWindowId) | select(.app == \"$1\")")

currentDisplay=$(echo "$currentWindow" | jq -r ".display")
if [ -z "$currentDisplay" ]
then
    currentDisplay="1"
fi

currentSpace=$(echo "$currentWindow" | jq -r ".space")

appIsFocused=$(echo "$currentWindow" | jq -r "select (.app == \"$1\") | .id" | head -n 1)
if [ -n "$appIsFocused" ]
then
    echo app is focused
fi

function switchAndExit {
    echo checking whether app is $2 using $1
    local window=$(echo "$windowsForApp" | jq -r "select($1) | .id" | head -n 1)
    if [ -n "$window" ]
    then
        echo app is "$2"
        yabai -m window --focus "$window" && exit
    fi
}

switchAndExit ".space == $currentSpace and .display == $currentDisplay" "on current space"

switchAndExit ".display == $currentDisplay and .space != $currentSpace" "on current display"

switchAndExit ".display != $currentDisplay" "somewhere else"

