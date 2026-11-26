#!/bin/bash

# Current/next Outlook meeting, next to the clock:
#   "Focus time in progress" / "Standup in 5 min" / "1:1 at 14:00"
#   a daily joke line ("Meetings: 0. Vibes: 100") when nothing is left today.
#
# NextMeeting.app (pkgs/next-meeting, path passed as $1) reads macOS Calendar
# and writes the event to a cache file (see its main.swift). It's launched on every run to refresh the file;
# `open` returns immediately, so this run shows the previous refresh (at most
# one update_freq old). The countdown is always computed fresh from the
# event's start time, so it never lags.

source "$(dirname "$0")/../colors.sh"

HELPER="$1"
CACHE="$HOME/Library/Caches/sketchybar/next_meeting.tsv"

# A helper instance that hangs or gets suspended (seen after sleep: state "T")
# blocks every later `open` (error -600), freezing the cache forever. If the
# cache is over 5 minutes old, kill any leftover instance before launching.
if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(stat -f %m "$CACHE") )) -gt 300 ]; then
	pkill -9 -f "NextMeeting.app/Contents/MacOS/NextMeeting"
fi

open -g -j "$HELPER"

line="$(cat "$CACHE" 2>/dev/null)"

if [ "$line" = "!denied" ]; then
	sketchybar --set "$NAME" drawing=on icon.color=$DIM label.color=$DIM \
		label="Calendar access needed"
	exit 0
fi

IFS=$'\t' read -r title start end <<< "$line"
now=$(date +%s)

if [ -z "$title" ] || [ "$end" -le "$now" ]; then
	# One line per day, so it doesn't change every 30 seconds.
	# 10# forces base 10: %j is zero-padded and "08" would be read as octal.
	FREE=(
		"No meetings. Suspicious."
		"Calendar empty, go touch grass"
		"Meetings: 0. Vibes: 100"
		"Nothing booked. Look busy anyway"
		"Free as a bird"
		"Zero meetings, maximum snacks"
		"This could have been an email. It was."
	)
	line="${FREE[$(( 10#$(date +%j) % ${#FREE[@]} ))]}"
	# 󰂒 = nf-md-beach
	sketchybar --set "$NAME" drawing=on icon=󰂒 icon.color=$GREEN \
		label.color=$SUBTEXT label="$line"
	exit 0
fi

if [ "$start" -le "$now" ]; then
	when="in progress"; urgent=1
else
	mins=$(( (start - now + 59) / 60 ))
	if [ $mins -le 60 ]; then
		when="in $mins min"
	else
		when="at $(date -r "$start" +%H:%M)"
	fi
	[ $mins -le 10 ] && urgent=1 || urgent=0
fi

if [ "$urgent" = 1 ]; then icon_color=$ORANGE; else icon_color=$BLUE; fi

# 󰃰 = nf-md-calendar_clock
sketchybar --set "$NAME" drawing=on icon=󰃰 icon.color=$icon_color label.color=$TEXT \
	label="$title $when"
