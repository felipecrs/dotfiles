#!/bin/bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
dotfiles_root="$(realpath "$script_dir/..")"

set -x

docker run --rm -e REMOTE_CONTAINERS=true -u vscode -v "$dotfiles_root:/home/vscode/.dotfiles:ro" -w /home/vscode/.dotfiles mcr.microsoft.com/vscode/devcontainers/base:ubuntu ./install
