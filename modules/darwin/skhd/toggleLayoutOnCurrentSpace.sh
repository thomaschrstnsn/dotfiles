#!/bin/sh

CurrentlyFocusedWindow=$(yabai -m query --windows --window | jq -re ".")
CurrentlyFocusedWindowID=$(echo $CurrentlyFocusedWindow | jq -re ".id")
CurrentlyFocusedSpace=$(echo $CurrentlyFocusedWindow | jq -re ".space")

CurrentType=$(yabai -m query --spaces --space $CurrentlyFocusedSpace | jq -r ".type")

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

$(yabai -m space $CurrentlyFocuseSpace --layout $NextType)
