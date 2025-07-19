#! /usr/bin/env bash

activeWindow=$(hyprctl -j activewindow | jq -r .class)

echo active "$activeWindow"

if [[ "$activeWindow" == "org.wezfurlong.wezterm" || "$activeWindow" == "com.mitchellh.ghostty" ]];
then
	echo "term"
	hyprctl dispatch sendshortcut CTRL+SHIFT,  V, activewindow
else
	echo "not term"
	hyprctl dispatch sendshortcut CTRL, V, activewindow
fi

