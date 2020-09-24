#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -euox pipefail

docker run --rm -e REMOTE_CONTAINERS=true -u vscode -v "$script_dir:/home/vscode/.dotfiles:ro" -w /home/vscode/.dotfiles mcr.microsoft.com/vscode/devcontainers/base:ubuntu ./install
