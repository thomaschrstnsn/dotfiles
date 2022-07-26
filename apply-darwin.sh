#! /usr/bin/env bash
set -e

./build-darwin.sh "$*"

DEFAULT_CONFIGURATION="$(hostname -s)"
if [[ $1 == "--"* ]] || [[ $# -eq 0 ]];
then
    CONFIGURATION=$DEFAULT_CONFIGURATION
else
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
fi

echo activating darwin "$CONFIGURATION"
./result/sw/bin/darwin-rebuild switch --flake .\#"$CONFIGURATION" "$@"
