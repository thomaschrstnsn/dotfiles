#!/bin/bash

WINDOW_TITLE=$(yabai -m query --windows --window | jq -r '.title')
WINDOW_APP=$(yabai -m query --windows --window | jq -r '.app')
LABEL="$WINDOW_APP - $WINDOW_TITLE"

if [[ ${#LABEL} -gt 50 ]]; then
  LABEL="$(echo "$LABEL" | cut -n -b 1-50)…"
fi

sketchybar -m --set title label="│ $LABEL"