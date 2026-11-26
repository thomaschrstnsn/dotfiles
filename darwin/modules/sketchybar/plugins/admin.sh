#!/bin/bash

# Admin By Request: shows whether this user currently has admin rights
# (an Admin By Request session adds the user to the admin group).
#   on:  key icon + "Admin" in love (red)
#   off: dim account icon
# No event fires when a session starts or ends, so this is polled; the click
# (sketchybarrc) opens Admin By Request's "request admin" dialog.

source "$(dirname "$0")/../colors.sh"

if dseditgroup -o checkmember -m "$(id -un)" admin >/dev/null 2>&1; then
	# 󰌆 = nf-md-account_key
	sketchybar --set "$NAME" icon=󰌆 icon.color=$RED label="Admin" label.drawing=on \
		icon.padding_right=6
else
	# 󰀓 = nf-md-account_outline
	sketchybar --set "$NAME" icon=󰀓 icon.color=$DIM label.drawing=off \
		icon.padding_right=9
fi
