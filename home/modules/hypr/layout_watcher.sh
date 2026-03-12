#!/usr/bin/env bash

# This script listens to Hyprland IPC events and applies the correct layout
# when switching workspaces, mimicking per-workspace layouts.

# Exit if socket2 is not found
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "HYPRLAND_INSTANCE_SIGNATURE is not set."
    exit 1
fi

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprland_layout_state"
mkdir -p "$STATE_DIR"

# Helper function to apply layout for a given workspace
apply_layout() {
    local workspace="$1"
    local state_file="$STATE_DIR/$workspace"
    local target_layout="master" # Default fallback layout

    if [[ -f "$state_file" ]]; then
        target_layout=$(cat "$state_file")
    fi

    # Dispatch to update global layout
    hyprctl keyword general:layout "$target_layout" > /dev/null
}

# Listen to the Hyprland socket for workspace change events
# We use netcat (nc -U) to read the UNIX socket stream
nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    # The event format for workspace change is typically: workspace>><workspace_name>
    if [[ "$line" == workspace\>\>* ]]; then
        # Extract the workspace name
        workspace_name="${line#workspace>>}"
        apply_layout "$workspace_name"
    fi
done
