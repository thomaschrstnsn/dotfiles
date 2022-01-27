#! /bin/bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
if [[ $1 != "--"* ]];
then
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
else
    CONFIGURATION=$DEFAULT_CONFIGURATION
fi

echo building darwin "$CONFIGURATION" configuration

nix build .#darwinConfigurations."$CONFIGURATION".system "$@"

echo successfully built darwin "$CONFIGURATION"

