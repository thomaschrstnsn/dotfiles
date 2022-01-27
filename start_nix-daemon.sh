#! /bin/bash

daemon=$(pgrep nix-daemon)

if [[ $daemon ]];
then
    echo "found running daemon, refusing to continue"
    echo process id: $daemon
    exit 1
fi

generation=$(darwin-rebuild --list-generations | tail -n 1 | awk '{print $1}')

# ps ax | grep bin/nix-daemon

echo switching to latest nix-darwin generation to start nix-daemon
echo generation: "$generation"

read -p "Are you sure? " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; 
then
    darwin-rebuild --switch-generation "$generation"
fi
