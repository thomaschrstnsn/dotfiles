#! /usr/bin/env bash
set -e

DEFAULT_CONFIGURATION="$(hostname -s).$(echo "${USER}" | sed s/\\./_/g)" # replace . -> _

if [[ $1 == "--"* ]] || [[ $# -eq 0 ]];
then
    CONFIGURATION=$DEFAULT_CONFIGURATION
else
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
fi

echo building "$CONFIGURATION" configuration

nix build .#homeManagerConfigurations."$CONFIGURATION".activationPackage "$@"

echo successfully built "$CONFIGURATION"

