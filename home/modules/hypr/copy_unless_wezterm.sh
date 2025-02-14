#! /usr/bin/env bash

activeWindow=$(hyprctl -j activewindow | jq -r .class)

echo active "$activeWindow"

if [ "$activeWindow" == "org.wezfurlong.wezterm" ];
then
	echo "wezterm"
	hyprctl dispatch sendshortcut CTRL+SHIFT, C, activewindow
else
	echo "not wezterm"
	hyprctl dispatch sendshortcut CTRL, C, activewindow
fi

