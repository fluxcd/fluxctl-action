#!/bin/sh -l

mkdir -p $GITHUB_WORKSPACE/bin
cp /usr/local/bin/fluxctl $GITHUB_WORKSPACE/bin

echo "::add-path::$GITHUB_WORKSPACE/bin"
echo "::add-path::$RUNNER_WORKSPACE/$(basename $GITHUB_REPOSITORY)/bin"
