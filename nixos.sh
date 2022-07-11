#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION=$DEFAULT_CONFIGURATION

COMMAND=$1

echo building system "$CONFIGURATION" configuration with command $COMMAND

nixos-rebuild $COMMAND --flake .#

echo successfully built system "$CONFIGURATION"
