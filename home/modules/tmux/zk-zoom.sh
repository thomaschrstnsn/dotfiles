#!/usr/bin/env bash

# Show the zk notes pane full-screen in the current window.
#
# This used to use `display-popup -E "tmux attach-session"`. It doesn't any
# more: while a popup overlay is on screen tmux stops emitting synchronised
# output (CSI ?2026h) altogether, so a single nvim repaint reaches the terminal
# as ~30 unframed partial writes instead of 2 atomic frames. The terminal then
# composites every intermediate state, which is very visible when leaving
# insert mode. A zoomed pane looks the same and keeps the frame batching.
#
# The pane itself is shared with zk-toggle.sh and lives in $ZK_SESSION while
# hidden; @zk_pane tracks it as "<pane_id>:<window_id>".

ZK_SESSION="zk_personal"

stored_value=$(tmux show -gqv "@zk_pane")

if [ -n "$stored_value" ]; then
  pane_id="${stored_value%:*}"
else
  pane_id=""
fi

remember() {
  local id="$1"
  tmux set -g "@zk_pane" "$id:$(tmux display-message -p -t "$id" "#{window_id}")"
}

ensure_session() {
  if ! tmux has-session -t "$ZK_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$ZK_SESSION"
  fi
}

unzoom() {
  if [ "$(tmux display-message -p '#{window_zoomed_flag}')" = "1" ]; then
    tmux resize-pane -Z
  fi
}

# Pane is already in this window
if [ -n "$pane_id" ] && tmux list-panes -F "#{pane_id}" | grep -q "^$pane_id$"; then
  zoomed=$(tmux display-message -p '#{window_zoomed_flag}')
  active=$(tmux display-message -p '#{pane_id}')

  # Zoomed and focused -> this is the "close it" press: park it back
  if [ "$zoomed" = "1" ] && [ "$active" = "$pane_id" ]; then
    tmux resize-pane -Z
    ensure_session
    if tmux break-pane -d -s "$pane_id" -t "$ZK_SESSION:" 2>/dev/null; then
      remember "$pane_id"
    fi
    exit 0
  fi

  # Sitting there as a split (from zk-toggle.sh) -> promote it to full screen
  unzoom
  tmux select-pane -t "$pane_id"
  tmux resize-pane -Z -t "$pane_id"
  exit 0
fi

# Not in this window: bring it in
ensure_session
unzoom

pane_exists=false
if [ -n "$pane_id" ] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^$pane_id$"; then
  pane_exists=true
fi

tmux select-pane -t 0

if [ "$pane_exists" = true ]; then
  if ! tmux join-pane -h -s "$pane_id" 2>/dev/null; then
    pane_exists=false
  fi
fi

if [ "$pane_exists" = false ]; then
  tmux split-window -h
  pane_id=$(tmux display-message -p "#{pane_id}")
  tmux send-keys -t "$pane_id" "zk sync && zk daily && zk sync" Enter
fi

tmux select-pane -t "$pane_id"
remember "$pane_id"
tmux resize-pane -Z -t "$pane_id"
