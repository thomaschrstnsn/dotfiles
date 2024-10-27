#! /usr/bin/env bash

activeWindow=$(hyprctl -j activewindow | jq -r .class)

echo active "$activeWindow"

if [ "$activeWindow" == "org.wezfurlong.wezterm" ];
then
	echo "wezterm"
else
	echo "not wezterm"
	hyprctl dispatch sendshortcut CTRL, Z, activewindow
fi

