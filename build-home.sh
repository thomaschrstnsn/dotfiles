#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s).$(echo "${USER}" | sed s/\\./_/g)" # replace . -> _

if [[ $1 != "--"* ]];
then
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
else
    CONFIGURATION=$DEFAULT_CONFIGURATION
fi

echo building "$CONFIGURATION" configuration

nix build .#homeManagerConfigurations."$CONFIGURATION".activationPackage "$@"

echo successfully built "$CONFIGURATION"

