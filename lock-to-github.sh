#!/bin/sh -e

if [ -z "$1" ]
then
    possible=$(jq -r '.nodes | keys[]' flake.lock)
    echo tries to parse flake.lock, input one of possible keys
    echo "$possible"
    exit 1
fi

rev=$(jq -r ".nodes.\"$1\".locked.rev" flake.lock)

owner=$(jq -r ".nodes.\"$1\".locked.owner" flake.lock)
repo=$(jq -r ".nodes.\"$1\".locked.repo" flake.lock)
ref=$(jq -r ".nodes.\"$1\".original.ref // \"master\"" flake.lock)

echo current rev: "$rev"

compare="https://github.com/${owner}/${repo}/compare/${rev}...${ref}"
echo compare unstable with current: 
echo "$compare"

tree="https://github.com/${owner}/${repo}/tree/${rev}"
echo current tree: 
echo "$tree"

