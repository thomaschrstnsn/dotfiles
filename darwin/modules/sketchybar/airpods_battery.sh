if [ "$SENDER" == "mouse.clicked" ]; then
  sketchybar -m --set "$NAME" popup.drawing=toggle
fi

DEVICE_ADDRESS="AC:1D:06:0B:7A:6B"

DEVICE=$(system_profiler SPBluetoothDataType -json -detailLevel basic 2>/dev/null | jq '.SPBluetoothDataType' | jq '.[0]' | jq '.devices_list' | jq -r ".[] | select(.[] .device_address==\"$DEVICE_ADDRESS\") | .[]")

CONNECTED="$(echo "$DEVICE" | jq -r '.device_connected=="Yes"')"

if [ "$CONNECTED" = "true" ]; then
  LEFT=$( echo "$DEVICE" | jq -r '.device_batteryLevelLeft'  | sed 's/[^0-9]//g')
  RIGHT=$(echo "$DEVICE" | jq -r '.device_batteryLevelRight' | sed 's/[^0-9]//g')
  CASE=$( echo "$DEVICE" | jq -r '.device_batteryLevelCase'  | sed 's/[^0-9]//g')

  WARNING_LEVEL=25
  if [ $LEFT -le $WARNING_LEVEL ] || [ $RIGHT -le $WARNING_LEVEL ] || [ $CASE -le $WARNING_LEVEL ]; then
    sketchybar -m --set "$NAME" icon.highlight=on
  else
    sketchybar -m --set "$NAME" icon.highlight=off
  fi

  sketchybar -m --set "$NAME".left  label="$LEFT"%
  sketchybar -m --set "$NAME".right label="$RIGHT"%
  sketchybar -m --set "$NAME".case  label="$CASE"%

  sketchybar -m --set "$NAME" drawing=on
else
  sketchybar -m --set "$NAME" drawing=off
  sketchybar -m --set "$NAME" popup.drawing=off
fi
