#! /usr/bin/env bash

activeWindow=$(hyprctl -j activewindow | jq -r .class)

echo active "$activeWindow"

if [[ "$activeWindow" == "org.wezfurlong.wezterm" || "$activeWindow" == "com.mitchellh.ghostty" ]];
then
	echo "term"
	hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL+SHIFT", key = "C", window = "activewindow" })'
else
	echo "not term"
	hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "C", window = "activewindow" })'
fi

