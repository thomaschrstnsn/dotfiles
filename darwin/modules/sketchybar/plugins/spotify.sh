#!/bin/bash

# Spotify pill: a note that bobs up and down while playing, then "Artist - Track".
# Every second (routine) the note glides to the other end of its bob; Spotify
# itself is asked only when it reports a change (spotify_change) or on
# startup (forced).

source "$(dirname "$0")/../colors.sh"

STATE="${TMPDIR:-/tmp}/sketchybar_spotify_state"  # "playing" or anything else
BOB=2  # px above/below centre

if [ "$SENDER" = "routine" ]; then
	[ "$(cat "$STATE" 2>/dev/null)" = "playing" ] || exit 0
	if [ $(( $(date +%s) % 2 )) = 0 ]; then y=$BOB; else y=-$BOB; fi
	# 60 frames = 1s, so each glide ends just as the next tick starts one.
	sketchybar --animate sin 60 --set "$NAME" icon.y_offset=$y
	exit 0
fi

hide() {
	echo stopped > "$STATE"
	sketchybar --set "$NAME" drawing=off icon.y_offset=0 --set "sep.$NAME" drawing=off
	exit 0
}

# Guard with pgrep: `tell application` would otherwise launch Spotify just to
# ask it what it is playing.
pgrep -xq Spotify || hide

PLAYER="$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)"
[ "$PLAYER" = "playing" ] || [ "$PLAYER" = "paused" ] || hide

TRACK="$(osascript -e 'tell application "Spotify" to (artist of current track) & " - " & (name of current track)' 2>/dev/null)"
echo "$PLAYER" > "$STATE"

if [ "$PLAYER" = "playing" ]; then
	sketchybar --set "sep.$NAME" drawing=on --set "$NAME" drawing=on label="$TRACK" label.color=$TEXT icon.color=$GREEN
else
	# Paused: note settles back to centre, everything dimmed
	sketchybar --animate sin 30 --set "$NAME" icon.y_offset=0
	sketchybar --set "sep.$NAME" drawing=on --set "$NAME" drawing=on label="$TRACK" label.color=$DIM icon.color=$DIM
fi
