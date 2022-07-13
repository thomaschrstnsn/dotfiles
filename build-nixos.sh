#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo building system "$CONFIGURATION" configuration

nixos-rebuild build --flake .#"$CONFIGURATION"

echo successfully built system "$CONFIGURATION"
