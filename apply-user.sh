#! /bin/sh
set -e

./build-user.sh $*

echo activating
./result/activate