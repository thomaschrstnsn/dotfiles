#! /bin/sh

sudo nixos-install --flake .#"$1" \
  --option extra-substituters "https://cache.garnix.io https://nix-community.cachix.org" \
  --option extra-trusted-public-keys "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
