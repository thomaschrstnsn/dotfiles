#!/bin/sh

# Current aerospace workspace. aerospace's exec-on-workspace-change (set in
# darwin/modules/sketchybar.nix) triggers aerospace_workspace_change with the
# workspace in $FOCUSED_WORKSPACE; on startup/reload/wake ask aerospace.
if [ "$SENDER" = "aerospace_workspace_change" ]; then
	WS="$FOCUSED_WORKSPACE"
else
	WS="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

[ -n "$WS" ] && sketchybar --set "$NAME" label="$WS"
