#!/bin/bash

# Keep-awake toggle. Click starts `caffeinate -di` (no display sleep, no idle
# sleep); click again stops it. Full cup + "Awake" while on, dim empty cup off.
#   caffeinate.sh          - show current state (run by sketchybar)
#   caffeinate.sh toggle   - switch on/off
#
# The caffeinate pid is kept in a file, so only the one started here is ever
# stopped. Restarting sketchybar (its launchd agent) also ends it.

source "$(dirname "$0")/../colors.sh"

ITEM=caffeinate
PIDFILE="${TMPDIR:-/tmp}/sketchybar_caffeinate.pid"

running() {
	[ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

show() {
	if running; then
		sketchybar --set $ITEM icon=󰅶 icon.color=$ORANGE label="Awake" label.drawing=on \
			icon.padding_right=6
	else
		sketchybar --set $ITEM icon=󰛊 icon.color=$DIM label.drawing=off \
			icon.padding_right=9
	fi
}

if [ "$1" = "toggle" ]; then
	if running; then
		kill "$(cat "$PIDFILE")" 2>/dev/null
		rm -f "$PIDFILE"
	else
		nohup caffeinate -di >/dev/null 2>&1 &
		echo $! > "$PIDFILE"
	fi
fi

show
