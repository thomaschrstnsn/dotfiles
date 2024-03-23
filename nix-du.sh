#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-du graphviz

set -x 
nix-du -s=500MB | dot -Tsvg > store.svg

