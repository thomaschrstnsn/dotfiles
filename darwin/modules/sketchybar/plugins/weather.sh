#!/bin/bash

# Weather from wttr.in (no API key), e.g. "󰖗 🏠 12° Light rain".
#   weather.sh <location> <tag>
# Use "Town,Denmark": bare Danish postcodes resolve to the wrong place
# (wttr.in/8000 is somewhere 29° warm), and without a location wttr.in
# guesses from the public IP.
# On a network error the last value stays, rather than blanking the item.

source "$(dirname "$0")/../colors.sh"

LOC="$1"
TAG="$2"
URL="https://wttr.in/$LOC?format=%t|%C|%x&m"

data="$(curl -sf -m 10 "$URL")" || exit 0
IFS='|' read -r temp condition symbol <<< "$data"
[ -z "$temp" ] && exit 0

temp="${temp#+}"                                    # "+12°C" -> "12°C"
temp="${temp%C}"                                    # -> "12°"
condition="$(echo "$condition" | sed 's/ *$//')"   # wttr pads with spaces

# %x is wttr's plain-text weather symbol; map it to a Nerd Font icon.
hour=$((10#$(date +%H)))
night=0; { [ $hour -ge 20 ] || [ $hour -lt 6 ]; } && night=1

case "$symbol" in
	o)                if [ $night = 1 ]; then icon=󰖔; else icon=󰖙; fi ;;  # clear
	m)                if [ $night = 1 ]; then icon=󰼱; else icon=󰖕; fi ;;  # partly cloudy
	mm|mmm)           icon=󰖐 ;;  # cloudy
	=)                icon=󰖑 ;;  # fog
	/|.)              icon=󰖗 ;;  # light rain / showers
	//|///)           icon=󰖖 ;;  # heavy rain
	'*'|'*/'|x|x/)    icon=󰖘 ;;  # snow / sleet
	'**'|'*/*')       icon=󰼶 ;;  # heavy snow
	*'!'*)            icon=󰙾 ;;  # thunder
	*)                icon=󰖐 ;;
esac

sketchybar --set "$NAME" drawing=on icon="$icon" label="${TAG:+$TAG }$temp $condition"
