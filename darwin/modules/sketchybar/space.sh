#!/bin/bash

DRAWING="true"
if [ "$SELECTED" = "false" ]
then
    DRAWING="false";
fi;

sketchybar -m --set "$NAME" icon.highlight="$SELECTED" label.highlight="$SELECTED" drawing="$DRAWING"

