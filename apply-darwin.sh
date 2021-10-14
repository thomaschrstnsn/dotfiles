#! /bin/sh
set -e

./build-darwin.sh $*


DEFAULT_CONFIGURATION="`hostname -s`"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo activating darwin $CONFIGURATION
./result/sw/bin/darwin-rebuild switch --flake .\#$CONFIGURATION
