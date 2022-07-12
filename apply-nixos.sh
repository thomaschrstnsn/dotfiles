#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s)"
CONFIGURATION=$DEFAULT_CONFIGURATION

echo activating system "$CONFIGURATION" configuration

sudo nixos-rebuild switch --flake .#

echo successfully activated system "$CONFIGURATION"
