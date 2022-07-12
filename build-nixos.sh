#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION=$DEFAULT_CONFIGURATION

echo building system "$CONFIGURATION" configuration

nixos-rebuild build --flake .#

echo successfully built system "$CONFIGURATION"
