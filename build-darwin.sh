#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"

if [[ $1 == "--"* ]] || [[ $# -eq 0 ]];
then
    CONFIGURATION=$DEFAULT_CONFIGURATION
else
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
fi

echo building darwin "$CONFIGURATION" configuration

nix build .#darwinConfigurations."$CONFIGURATION".system "$@"

echo successfully built darwin "$CONFIGURATION"

