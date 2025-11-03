#!/bin/bash

# Get current session ID for per-session storage
current_session=$(tmux display-message -p "#{session_id}")
agent_var="@agent_pane_${current_session}"

stored_value=$(tmux show -gqv "$agent_var")

if [ -n "$stored_value" ]; then
  pane_id="${stored_value%:*}"
  stored_window_id="${stored_value#*:}"
else
  pane_id=""
  stored_window_id=""
fi

# Check if pane exists in current window
if [ -n "$pane_id" ] && tmux list-panes -F "#{pane_id}" | grep -q "^$pane_id$"; then
  # Pane is in current window - check if it's active
  current_pane=$(tmux display-message -p "#{pane_id}")
  
  if [ "$pane_id" = "$current_pane" ]; then
    # Pane is active - HIDE it by breaking to new window in same session
    if tmux break-pane -d -s "$pane_id" 2>/dev/null; then
      new_window_id=$(tmux display-message -p -t "$pane_id" "#{window_id}")
      tmux set -g "$agent_var" "$pane_id:$new_window_id"
    fi
  else
    # Pane exists but is not active - FOCUS it
    tmux select-pane -t "$pane_id"
  fi
  exit 0
fi

# Pane is not in current window - SHOW it

# Check if stored pane exists in the expected window
pane_valid=false
if [ -n "$pane_id" ] && [ -n "$stored_window_id" ]; then
  pane_window=$(tmux list-panes -a -F "#{pane_id}:#{window_id}" 2>/dev/null | grep "^$pane_id:" | cut -d: -f2)
  if [ "$pane_window" = "$stored_window_id" ]; then
    pane_valid=true
  fi
fi

# If pane is valid, try to join it back
if [ "$pane_valid" = true ]; then
  width=$(tmux display-message -p "#{pane_width}")
  agent_width=$((width * 45 / 100))

  tmux select-pane -t 0
  if tmux join-pane -h -l $agent_width -s "$pane_id" 2>/dev/null; then
    tmux select-pane -t "$pane_id"
    new_window_id=$(tmux display-message -p -t "$pane_id" "#{window_id}")
    tmux set -g "$agent_var" "$pane_id:$new_window_id"
    exit 0
  fi
fi

# Pane doesn't exist, is invalid, or join failed - create new one
tmux select-pane -t 0
tmux split-window -h -l 45%
new_pane_id=$(tmux display-message -p "#{pane_id}")
new_window_id=$(tmux display-message -p "#{window_id}")
tmux set -g "$agent_var" "$new_pane_id:$new_window_id"

tmux send-keys -t "$new_pane_id" "opencode" Enter
