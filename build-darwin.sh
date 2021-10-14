#! /bin/sh
set -e

DEFAULT_CONFIGURATION="`hostname -s`"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo building darwin $CONFIGURATION configuration

nix build .#darwinConfigurations.$CONFIGURATION.system

echo successfully built darwin $CONFIGURATION

