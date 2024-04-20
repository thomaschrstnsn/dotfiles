#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nvd

set -x 
nvd diff "$@"
