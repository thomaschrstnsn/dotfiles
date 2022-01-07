#!/bin/bash

args=()

while read -r index window
do
  if [ "$window" = "null" ]
  then
    args+=(--set "space${index}" label=)
  else
    app=$(yabai -m query --windows --window "$window" | jq -r '.app')
    case "$app" in
        "Microsoft Edge")
        label=""
        ;;
        "JetBrains Rider")
        label=""
        ;;
        "Safari")
        label=""
        ;;
        "iTerm2")
        label=""
        ;;
        "Code")
        label=""
        ;;
        *)
        label="°"
        ;;
    esac
    args+=(--set "space${index}" label="$label")
  fi
done <<< "$(yabai -m query --spaces | jq -r '.[] | [.index, .windows[0]] | @sh')"

sketchybar -m "${args[@]}"
