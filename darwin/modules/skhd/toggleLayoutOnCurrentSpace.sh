#!/bin/sh

CurrentlyFocusedWindow=$(yabai -m query --windows --window | jq -re ".")
CurrentlyFocusedSpace=$(echo "$CurrentlyFocusedWindow" | jq -re ".space")

CurrentType=$(yabai -m query --spaces --space "$CurrentlyFocusedSpace" | jq -r ".type")

case $CurrentType in
'bsp')
    NextType='float'
    ;;
'float')
    NextType='stack'
    ;;
'stack')
    NextType='bsp'
    ;;
esac

yabai -m space "$CurrentlyFocusedSpace" --layout $NextType
terminal-notifier -title yabai -message $NextType