#! /bin/sh

CONFIGURATION="`hostname -s`.${USER}"

echo applying $CONFIGURATION configuration

nix build .#homeManagerConfigurations.$CONFIGURATION.activationPackage
# ./result/activate