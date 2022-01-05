#!/bin/zsh

# window title
data=$(yabai -m query --windows --window)

window_title=$(echo $data | jq -r '.title' \
    | sed 's/ - Eric (Person [[:digit:]])$//g' \
    | sed 's/ - Google Chrome$//g' \
    | sed 's/ - Audio playing$//g' \
    | sed 's/ - Camera or microphone recording$//g' \
    | sed 's/ - Part of group ..*$//g')

[ "${#window_title}" -gt 40 ] && window_title="$(echo $window_title | head -c 40)…"

# app name

app_name=$(echo $data | jq -r '.app')

[ "${#app_name}" -gt 20 ] && app_name="$(echo $app_name | head -c 20)…"

# setting items

sketchybar -m \
    --set app_name \
        label="$app_name" \
        drawing=$([ -z "$app_name" ] && echo off || echo on) \
    --set window \
        label="$window_title" \
        drawing=$([ -z "$window_title" ] && echo off || echo on)