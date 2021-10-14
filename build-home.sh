#! /bin/sh
set -e

DEFAULT_CONFIGURATION="`hostname -s`.${USER}"
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo building $CONFIGURATION configuration

nix build .#homeManagerConfigurations.$CONFIGURATION.activationPackage

echo successfully built $CONFIGURATION

