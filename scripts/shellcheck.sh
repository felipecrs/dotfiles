#!/usr/bin/env bash

exec docker run --rm --interactive --volume="${PWD}:/mnt" --workdir=/mnt koalaman/shellcheck:latest "$@"
