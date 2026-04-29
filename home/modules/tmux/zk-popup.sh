#!/usr/bin/env bash

ZK_SESSION="zk_personal"

# Don't open a popup when already inside the zk_personal session (i.e. inside the popup)
if [ "$(tmux display-message -p '#{session_name}')" = "$ZK_SESSION" ]; then
  tmux detach-client -s "$ZK_SESSION"
  exit 0
fi

stored_value=$(tmux show -gqv "@zk_pane")

if [ -n "$stored_value" ]; then
  pane_id="${stored_value%:*}"
else
  pane_id=""
fi

# If pane is currently joined into current window (split mode), park it back to zk_personal
if [ -n "$pane_id" ] && tmux list-panes -F "#{pane_id}" | grep -q "^$pane_id$"; then
  if ! tmux has-session -t "$ZK_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$ZK_SESSION"
  fi
  if tmux break-pane -d -s "$pane_id" -t "$ZK_SESSION:" 2>/dev/null; then
    new_window_id=$(tmux display-message -p -t "$pane_id" "#{window_id}")
    tmux set -g "@zk_pane" "$pane_id:$new_window_id"
  fi
fi

# Ensure session exists
if ! tmux has-session -t "$ZK_SESSION" 2>/dev/null; then
  tmux new-session -d -s "$ZK_SESSION"
fi

# If no valid pane exists anywhere, create one (first ever launch)
pane_exists=false
if [ -n "$pane_id" ] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^$pane_id$"; then
  pane_exists=true
fi

if [ "$pane_exists" = false ]; then
  tmux new-window -t "$ZK_SESSION"
  new_pane_id=$(tmux display-message -p -t "$ZK_SESSION" "#{pane_id}")
  new_window_id=$(tmux display-message -p -t "$ZK_SESSION" "#{window_id}")
  tmux set -g "@zk_pane" "$new_pane_id:$new_window_id"
  tmux send-keys -t "$new_pane_id" "zk sync && zk daily && zk sync" Enter
fi

# Hide the status bar — zk_personal is never viewed directly, no chrome needed
tmux set-option -t "$ZK_SESSION" status off

# Select the zk window so attach-session opens at the right place
zk_window_id=$(tmux show -gqv "@zk_pane")
zk_window_id="${zk_window_id#*:}"
[ -n "$zk_window_id" ] && tmux select-window -t "$zk_window_id" 2>/dev/null

# Show the zk_personal session in a popup — press d to close, pane stays parked
tmux display-popup -E -w 90% -h 90% "tmux attach-session -t $ZK_SESSION"
