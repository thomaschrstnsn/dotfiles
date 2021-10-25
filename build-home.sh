#! /bin/sh
set -e

DEFAULT_CONFIGURATION="`hostname -s`.`echo ${USER} | sed s/\\\\./_/g`" # replace . -> _
CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"

echo building $CONFIGURATION configuration

nix build .#homeManagerConfigurations.$CONFIGURATION.activationPackage

echo successfully built $CONFIGURATION

