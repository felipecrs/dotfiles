#!/usr/bin/env bash
#
# This script will only be run if chezmoi is older than 2.9.1,
# because otherwise the .chezmoiroot file will be honored.

set -euo pipefail

function log_color() {
  local color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

function log_red() {
  log_color "0;31" "$@"
}

function log_error() {
  log_red "❌" "$@"
}

function error() {
  log_error "$@"
  exit 1
}

error "
⚠️ Detected old chezmoi version

❌ Manual action needed. To continue, please run:

👉 brew upgrade chezmoi && chezmoi init --apply
"
