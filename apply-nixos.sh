#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo activating system "$CONFIGURATION" configuration

sudo nixos-rebuild switch --flake .#"$CONFIGURATION"

echo successfully activated system "$CONFIGURATION"
