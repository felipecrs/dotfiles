#!/usr/bin/env bash

# This script must exit as fast as possible when pre-requisites are already
# met, so we only import the scripts-library when we really need it.

set -eu

wanted_packages=(
  gpg # used to decrypt the gpg keys of the apt repositories
)

missing_packages=()

for package in "${wanted_packages[@]}"; do
  if ! command -v "${package}" >/dev/null; then
    missing_packages+=("${package}")
  fi
done

if [[ ${#missing_packages[@]} -eq 0 ]]; then
  exit 0
fi

# shellcheck source=../.chezmoitemplates/scripts-library
source "${CHEZMOI_SOURCE_DIR?}/.chezmoitemplates/scripts-library"

log_task "Installing missing pre-requisites with APT: ${missing_packages[*]}"

c apt update
c env DEBIAN_FRONTEND=noninteractive apt install --yes --no-install-recommends "${missing_packages[@]}"
