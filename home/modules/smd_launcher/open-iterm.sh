#! /usr/bin/env bash

PROFILE="${1-Default}"

osascript -e $"tell application \"iTerm\"
  create window with profile \"$PROFILE\"
end tell"