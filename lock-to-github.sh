#!/bin/sh -e

if [ -z "$1" ]
then
    possible=`cat flake.lock | jq -r '.nodes | keys[]'`
    echo tries to parse flake.lock, input one of possible keys
    echo $possible
    exit 1
fi

rev=`cat flake.lock | jq -r ".nodes.\"$1\".locked.rev"`

owner=`cat flake.lock | jq -r ".nodes.\"$1\".locked.owner"`
repo=`cat flake.lock | jq -r ".nodes.\"$1\".locked.repo"`
ref=`cat flake.lock | jq -r ".nodes.\"$1\".original.ref // \"master\""`

echo current rev: $rev

compare="https://github.com/${owner}/${repo}/compare/${rev}...${ref}"
echo compare unstable with current: 
echo $compare

tree="https://github.com/${owner}/${repo}/tree/${rev}"
echo current tree: 
echo $tree

