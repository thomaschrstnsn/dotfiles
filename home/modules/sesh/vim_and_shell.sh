#! /usr/bin/env bash
tmux new-window
tmux select-window -t 1
tmux send-keys "vim" Enter
