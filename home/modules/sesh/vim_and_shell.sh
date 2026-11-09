#! /usr/bin/env bash
# sesh runs this inside the session's first window, so reuse it for neovim
tmux new-window -d -n shell
tmux rename-window neovim
exec nvim
