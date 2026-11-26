#!/bin/bash

# Rosé Pine (main variant), matching tmux and lazyvim.
# Single source of colours: sourced by sketchybarrc and every plugin that
# sets a colour, so changing the theme means editing only this file.
# Format is 0xAARRGGBB. The variable names describe roles (BLUE, GREEN, ...)
# so the plugins read the same as with any other palette.

# Surfaces
export BAR=0xff191724    # base
export PILL=0xff1f1d2e   # surface (popups)
export BORDER=0xff403d52 # highlight med

# Text
export TEXT=0xffe0def4    # text
export SUBTEXT=0xff908caa # subtle
export DIM=0xff6e6a86     # muted (paused / off states)

# Accents
export BLUE=0xff9ccfd8    # foam
export CYAN=0xff9ccfd8    # foam
export BLUE1=0xff9ccfd8   # foam
export TEAL=0xff31748f    # pine
export GREEN=0xff31748f   # pine (rosé pine has no green)
export YELLOW=0xfff6c177  # gold
export ORANGE=0xffeb6f92  # love (urgent: meeting starting soon)
export MAGENTA=0xffc4a7e7 # iris
export RED=0xffeb6f92     # love

# Roles
export APP_NAME=0xffebbcba  # rose: active app name, centre of the bar
export CLOCK=0xfff6c177     # gold: date + clock
export SEP=0xff6e6a86       # muted: separator dots between right-side items
export WORKSPACE=0xffc4a7e7 # iris: aerospace workspace, far left
