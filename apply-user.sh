#! /bin/sh
set -e
CONFIGURATION="`hostname -s`.${USER}"

echo applying $CONFIGURATION configuration

nix build .#homeManagerConfigurations.$CONFIGURATION.activationPackage

echo activating
./result/activate