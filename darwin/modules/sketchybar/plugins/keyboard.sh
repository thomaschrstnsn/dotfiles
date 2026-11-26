#!/bin/sh

# Current keyboard layout as a country code, e.g. "DK" or "GB".
# Triggered by the input_change event (AppleSelectedInputSourcesChangedNotification,
# see sketchybarrc) and on startup/wake.

LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources \
	| sed -n 's/.*"KeyboardLayout Name" = "*\([^";]*\)"*;.*/\1/p' | head -1)"

case "$LAYOUT" in
	Danish*) CODE=DK ;;
	British*) CODE=GB ;;
	U.S.* | US* | ABC*) CODE=US ;;
	"") exit 0 ;;
	*) CODE="$(printf '%.2s' "$LAYOUT" | tr '[:lower:]' '[:upper:]')" ;;
esac

sketchybar --set "$NAME" label="$CODE"
