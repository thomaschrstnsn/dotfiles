#!/bin/zsh

# window title
data=$(yabai -m query --windows --window)

window_title=$(echo $data | jq -r '.title' \
    | sed 's/ - Google Chrome$//g' \
    | sed 's/ - Microsoft Edge$//g' \
    | sed 's/ - Brave$//g' \
    | sed 's/ - Audio playing$//g' \
    | sed 's/ - Camera or microphone recording$//g' \
    | sed 's/ - Part of group ..*$//g')

cutoff=80

[ "${#window_title}" -gt $cutoff ] && window_title="$(echo $window_title | head -c $cutoff)…"

# app name

app_name=$(echo $data | jq -r '.app')

case "$app_name" in
    "Brave Browser")
    app_name="Brave"
    ;;
    *)
    app_name="$app_name"
    ;;
esac

[ "${#app_name}" -gt 30 ] && app_name="$(echo $app_name | head -c 30)…"

# setting items

sketchybar -m \
    --set app_name \
        label="$app_name" \
        drawing=$([ -z "$app_name" ] && echo off || echo on) \
    --set window \
        label="$window_title" \
        drawing=$([ -z "$window_title" ] && echo off || echo on)