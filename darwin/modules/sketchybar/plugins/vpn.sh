#!/bin/bash

# VPN state from `scutil --nc list` (covers Azure VPN Client and any other
# Network Extension VPN). Icon only; its colour says the state:
#   foam = connected, gold = connecting/disconnecting, muted = off.
# macOS sends no VPN event sketchybar can hear, so this is polled.
# A click opens Azure VPN Client (set in sketchybarrc).

source "$(dirname "$0")/../colors.sh"

states="$(scutil --nc list | sed -n 's/^\*\{0,1\} *(\([A-Za-z]*\)).*/\1/p')"

if grep -qx Connected <<< "$states"; then
	sketchybar --set "$NAME" icon=󰕥 icon.color=$CYAN
elif grep -qxE 'Connecting|Disconnecting|Reasserting' <<< "$states"; then
	sketchybar --set "$NAME" icon=󰕥 icon.color=$YELLOW
else
	sketchybar --set "$NAME" icon=󰦞 icon.color=$DIM
fi
