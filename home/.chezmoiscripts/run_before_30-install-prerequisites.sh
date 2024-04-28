#!/bin/bash

# This script must not be a template, so that it gets executed before rendering
# the templates.

# shellcheck source=../.chezmoitemplates/scripts-library
source "${CHEZMOI_SOURCE_DIR?}/.chezmoitemplates/scripts-library"

wanted_packages=(
  git  # used to find the latest revisions of github repositories
  curl # used to find the latest version of github repositories
  zsh
)

ROOTMOI="${ROOTMOI:-}"
if [[ "${ROOTMOI}" == 1 ]]; then
  wanted_packages+=(
    gpg # used to decrypt the gpg keys of the apt repositories
  )
fi

missing_packages=()

for package in "${wanted_packages[@]}"; do
  if ! command -v "${package}" >/dev/null; then
    missing_packages+=("${package}")
  fi
done

if [[ ${#missing_packages[@]} -gt 0 ]]; then
  log_task "Installing missing packages with APT: ${missing_packages[*]}"

  # This script also gets called when running rootmoi
  if [[ "${ROOTMOI}" == 1 ]]; then
    apt_command=(apt)
  else
    apt_command=(sudo apt)
  fi

  c "${apt_command[@]}" update
  c "${apt_command[@]}" install --yes --no-install-recommends "${missing_packages[@]}"
fi
