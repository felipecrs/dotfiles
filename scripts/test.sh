#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
dotfiles_root="$(realpath "$script_dir/..")"

cmd() {
  echo "==>" "$@"
  "$@"
}

echo "Remote - Containers"
cmd docker run --rm -e REMOTE_CONTAINERS=true -u vscode -v "$dotfiles_root:/mnt/repo:ro" mcr.microsoft.com/vscode/devcontainers/base:ubuntu sh -c 'cp -r /mnt/repo ~/.dotfiles && ~/.dotfiles/install'

echo
echo "NOT Remote - Containers"
cmd docker run --rm -u vscode -v "$dotfiles_root:/mnt/repo:ro" mcr.microsoft.com/vscode/devcontainers/base:ubuntu sh -c 'cp -r /mnt/repo ~/.dotfiles && ~/.dotfiles/install'
