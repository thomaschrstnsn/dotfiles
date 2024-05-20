#!/bin/bash

STATUS="$HOME/.cache/sketchybar/status"

readable() {
  local bytes=$1
  local kib=$(( bytes >> 10 ))
  if [ "$kib" -lt 0 ]; then
    printf "?K"
  elif [ "$kib" -gt 1024 ]; then
    local mib_int=$(( kib >> 10 ))
    local mib_dec=$(( kib % 1024 * 976 / 10000 ))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    printf "%s.%sM" "$mib_int" "$mib_dec"
  else
    printf "%sK" "$kib"
  fi
}

get_wifi() {
  local wifi test
  wifi=$(networksetup -getairportnetwork en0)
  read -r _ _ test WIFI_LABEL <<< "$wifi"

  case "$WIFI_LABEL" in
    "Kroghsvej 22")
    WIFI_LABEL=""
    ;;
    "Schibsted Global")
    WIFI_LABEL=""
    ;;
    *)
    WIFI_LABEL="$WIFI_LABEL"
    ;;
  esac

  if [ "$test" = "Network:" ]
  then
      WIFI_ICON=""
      WIFI_PADDING=6
      NETWORK_IF="en0"
  else
      WIFI_LABEL=""
      WIFI_ICON="睊"
      WIFI_PADDING=0
      NETWORK_IF="en5"
  fi
}

get_network() {
  local network ibytes obytes last_ibytes last_obytes
  network=$(netstat -ibn -I $NETWORK_IF)
  network="${network##*"$NETWORK_IF"}"
  read -r _ _ _ _ _ ibytes _ _ obytes _ <<< "${network}"
  ISPEED="-1"
  OSPEED="-1"
  if [ -e "$STATUS" ]
  then
    read -r last_ibytes last_obytes < "$STATUS"
    ISPEED=$(( (ibytes - last_ibytes) / 10 ))
    OSPEED=$(( (obytes - last_obytes) / 10 ))
  fi
  echo "$ibytes $obytes" > "$STATUS"
}

get_wifi
get_network

sketchybar -m \
  --set clock label="$(date +'%R')" \
  --set date label="$(date +'W%W %d/%m/%y')" \
  --set wifi icon="$WIFI_ICON" icon.padding_right="$WIFI_PADDING" label="$WIFI_LABEL" \
  --set network.up label="↑$(readable "$OSPEED")" \
  --set network.down label="↓$(readable "$ISPEED")"
