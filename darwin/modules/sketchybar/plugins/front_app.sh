#!/bin/sh

# front_app_switched passes the newly focused app's name in $INFO.
# On startup/reload ($SENDER=forced) there is no $INFO, so ask Launch Services
# (same display name as $INFO; System Events gives process names like "ghostty").
if [ "$SENDER" = "front_app_switched" ]; then
	APP="$INFO"
else
	APP="$(lsappinfo info "$(lsappinfo front)" | head -1 | cut -d'"' -f2)"
fi

[ -n "$APP" ] && sketchybar --set "$NAME" label="$APP"
