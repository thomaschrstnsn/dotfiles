#!/bin/bash

ZK_SESSION="zk_personal"

stored_value=$(tmux show -gqv "@zk_pane")

if [ -n "$stored_value" ]; then
  pane_id="${stored_value%:*}"
  stored_window_id="${stored_value#*:}"
else
  pane_id=""
  stored_window_id=""
fi

# Check if pane exists in current window
if [ -n "$pane_id" ] && tmux list-panes -F "#{pane_id}" | grep -q "^$pane_id$"; then
  # Pane is in current window - HIDE it by moving to dedicated session
  
  # Ensure zk_personal session exists
  if ! tmux has-session -t "$ZK_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$ZK_SESSION"
  fi
  
  # Move pane to zk_personal session
  if tmux break-pane -d -s "$pane_id" -t "$ZK_SESSION:" 2>/dev/null; then
    new_window_id=$(tmux display-message -p -t "$pane_id" "#{window_id}")
    tmux set -g "@zk_pane" "$pane_id:$new_window_id"
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
  zk_width=$((width * 45 / 100))

  tmux select-pane -t 0
  if tmux join-pane -h -l $zk_width -s "$pane_id" 2>/dev/null; then
    tmux select-pane -t "$pane_id"
    new_window_id=$(tmux display-message -p -t "$pane_id" "#{window_id}")
    tmux set -g "@zk_pane" "$pane_id:$new_window_id"
    exit 0
  fi
fi

# Pane doesn't exist, is invalid, or join failed - create new one
tmux select-pane -t 0
tmux split-window -h -l 45%
new_pane_id=$(tmux display-message -p "#{pane_id}")
new_window_id=$(tmux display-message -p "#{window_id}")
tmux set -g "@zk_pane" "$new_pane_id:$new_window_id"

tmux send-keys -t "$new_pane_id" "zk daily" Enter
