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

if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  echo_task "Installing chezmoi to ${chezmoi}"
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL https://git.io/chezmoi)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- https://git.io/chezmoi)"
  else
    error "To install chezmoi, you must have curl or wget."
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
# shellcheck disable=SC2312
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

if [ -n "${DOTFILES_ONE_SHOT-}" ]; then
  chezmoi_extra_args="--one-shot"
else
  chezmoi_extra_args="--apply"
fi

if [ -n "${DOTFILES_DEBUG-}" ]; then
  chezmoi_extra_args="${chezmoi_extra_args} --debug"
fi

echo_task "Running chezmoi init"
# replace current process with chezmoi init
# shellcheck disable=SC2086
exec "${chezmoi}" init --source "${script_dir}" ${chezmoi_extra_args}
