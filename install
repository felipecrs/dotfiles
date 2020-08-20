#!/bin/sh

echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$*"
}

error() {
  printf "\033[0;31m%s\033[0m\n" "$*" >&2
  exit 1
}

# -e: exit on error
# -u: exit on unset variables
set -eu

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  echo_task "Installing chezmoi to $chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    error "To install chezmoi, you must have curl or wget."
  fi
else
  chezmoi=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
echo_task "Running chezmoi init"
# replace current process with chezmoi init
exec "$chezmoi" init --apply --source "$script_dir"
