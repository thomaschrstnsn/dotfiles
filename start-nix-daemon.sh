#! /usr/bin/env bash

# TODO: clue: https://github.com/LnL7/nix-darwin/blob/master/modules/services/nix-daemon.nix#L23-L33

daemon=$(pgrep nix-daemon)

if [[ $daemon ]];
then
    echo "found running daemon, refusing to continue"
    echo process id: "$daemon"
    exit 1
fi

generation=$(darwin-rebuild --list-generations | tail -n 1 | awk '{print $1}')

echo switching to latest nix-darwin generation to start nix-daemon
echo generation: "$generation"

read -p "Are you sure? " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; 
then
    darwin-rebuild --switch-generation "$generation"
fi
