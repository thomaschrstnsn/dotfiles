#!/bin/sh

# e.g. "W48 Wed 14 Oct  10:42:07" (ISO week, same as the tmux status line)
sketchybar --set "$NAME" label="$(date '+W%V %a %d %b  %H:%M:%S')"
