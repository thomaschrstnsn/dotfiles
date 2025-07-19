#! /usr/bin/env bash

activeWindow=$(hyprctl -j activewindow | jq -r .class)

echo active "$activeWindow"

if [[ "$activeWindow" == "org.wezfurlong.wezterm" || "$activeWindow" == "com.mitchellh.ghostty" ]];
then
	echo "term"
else
	echo "not term"
	hyprctl dispatch sendshortcut CTRL, Z, activewindow
fi

