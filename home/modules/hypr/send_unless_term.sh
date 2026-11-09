#! /usr/bin/env bash
# usage: send_unless_term.sh <mods> <key> [<term-mods>]
# Sends <mods>+<key> to the active window. In a terminal it sends
# <term-mods>+<key> instead, or nothing when <term-mods> is omitted.
set -e

mods="$1"
key="$2"
term_mods="${3-}"

active_window=$(hyprctl -j activewindow | jq -r .class)

if [[ "$active_window" == "org.wezfurlong.wezterm" || "$active_window" == "com.mitchellh.ghostty" ]]; then
	if [[ $# -lt 3 ]]; then
		exit 0
	fi
	mods="$term_mods"
fi

hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"$mods\", key = \"$key\", window = \"activewindow\" })"
