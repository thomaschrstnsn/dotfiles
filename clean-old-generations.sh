#! /bin/sh

# https://discourse.nixos.org/t/list-and-delete-nixos-generations/29637

sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 30d
