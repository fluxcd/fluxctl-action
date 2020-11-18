#!/bin/sh -l

mkdir -p $GITHUB_WORKSPACE/bin
cp /usr/local/bin/fluxctl $GITHUB_WORKSPACE/bin

echo "$GITHUB_WORKSPACE/bin" >> $GITHUB_PATH
echo "$RUNNER_WORKSPACE/$(basename $GITHUB_REPOSITORY)/bin" >> $GITHUB_PATH
