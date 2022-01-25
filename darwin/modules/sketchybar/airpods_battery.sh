DEVICE_ADDRESS="AC:1D:06:0B:7A:6B"

DEVICE=$(system_profiler SPBluetoothDataType -json -detailLevel basic 2>/dev/null | jq '.SPBluetoothDataType' | jq '.[0]' | jq '.devices_list' | jq -r ".[] | select(.[] .device_address==\"$DEVICE_ADDRESS\") | .[]")

CONNECTED="$(echo "$DEVICE" | jq -r '.device_connected=="Yes"')"

if [ "$CONNECTED" = "true" ]; then
  LEFT=$( echo "$DEVICE" | jq -r '.device_batteryLevelLeft'  | sed 's/[^0-9]//g')
  RIGHT=$(echo "$DEVICE" | jq -r '.device_batteryLevelRight' | sed 's/[^0-9]//g')
  CASE=$( echo "$DEVICE" | jq -r '.device_batteryLevelCase'  | sed 's/[^0-9]//g')

  if [ $LEFT = 0 ]; then
    LEFT="-"
  fi

  if [ $RIGHT = 0 ]; then
    RIGHT="-"
  fi

  if [ $CASE = 0 ]; then
    CASE=" "
  else
    CASE=" [$CASE] "
  fi

  LABEL="$LEFT$CASE$RIGHT"

  sketchybar -m --set "$NAME" drawing=on
  sketchybar -m --set "$NAME" label="$LABEL"
else
  sketchybar -m --set "$NAME" drawing=off
fi
