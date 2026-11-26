#!/bin/bash

# Connected Bluetooth audio device (headphones / speaker) and its battery.
# Hidden when none is connected.
#
# - Devices come from system_profiler; "audio" means it offers A2DP.
# - Battery comes from `pmset -g accps`, which lists accessory batteries by
#   device name (system_profiler leaves it out for e.g. Bose headphones).
#   Devices that don't report a battery show just the name.

source "$(dirname "$0")/../colors.sh"

devices="$(system_profiler SPBluetoothDataType -json 2>/dev/null | /usr/bin/python3 -I -c '
import json, sys
data = json.load(sys.stdin)["SPBluetoothDataType"][0]
for dev in data.get("device_connected") or []:
    for name, info in dev.items():
        if "A2DP" in info.get("device_services", ""):
            print(name + "\t" + info.get("device_minorType", ""))')"

if [ -z "$devices" ]; then
	sketchybar --set "$NAME" drawing=off --set "sep.$NAME" drawing=off
	exit 0
fi

batteries="$(pmset -g accps)"
labels=(); icon=󰋋; low=0
while IFS=$'\t' read -r name type; do
	pct="$(grep -F -- "-$name (" <<< "$batteries" | grep -Eo '[0-9]+%' | head -1)"
	if [ -n "$pct" ]; then
		labels+=("$name $pct")
		[ "${pct%\%}" -le 20 ] && low=1
	else
		labels+=("$name")
	fi
	case "$type" in
		*[Ss]peaker*) icon=󰓃 ;;
	esac
done <<< "$devices"

label="$(printf '%s, ' "${labels[@]}")"
label="${label%, }"
if [ "$low" = 1 ]; then color=$RED; else color=$BLUE1; fi

sketchybar --set "sep.$NAME" drawing=on --set "$NAME" drawing=on icon="$icon" icon.color=$color label="$label"
