#! /usr/bin/env bash

set -e

# Get current active workspace
WORKSPACE_NAME=$(hyprctl activeworkspace -j | jq -r '.name')

# There is no direct IPC way to get the *current* layout of a specific workspace
# in 0.53.3 if it's been dynamically changed.
# We'll use a local state file to track the toggle state per-workspace.
STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprland_layout_state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$WORKSPACE_NAME"

# Read current state or fallback to global default
if [ -f "$STATE_FILE" ]; then
    CURRENT_LAYOUT=$(cat "$STATE_FILE")
else
    # Fallback to the global layout defined in the config
    CURRENT_LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str')
fi

# Determine new layout
if [ "$CURRENT_LAYOUT" = "master" ]; then
    NEW_LAYOUT="dwindle"
else
    NEW_LAYOUT="master"
fi

# Apply the new layout to the current workspace via global layout switch
hyprctl keyword general:layout "$NEW_LAYOUT"

# Save the new state so the daemon knows what to do when we switch back to this workspace
echo "$NEW_LAYOUT" > "$STATE_FILE"

# Notify the user
notify-send -t 2000 "Workspace '$WORKSPACE_NAME' Layout" "$NEW_LAYOUT"