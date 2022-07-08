#!/bin/bash

DRAWING="true"
if [ "$SELECTED" = "false" ]
then
    DRAWING="false";
fi;

sketchybar -m --set "$NAME" label.highlight="$SELECTED" drawing="$DRAWING"

