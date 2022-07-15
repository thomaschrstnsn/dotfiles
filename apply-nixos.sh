#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo activating system "$CONFIGURATION" configuration

nixos-rebuild switch --use-remote-sudo --flake .#"$CONFIGURATION"

echo successfully activated system "$CONFIGURATION"
