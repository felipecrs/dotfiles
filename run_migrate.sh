#!/bin/bash
#
# This script will only be run if chezmoi is older than 2.9.1,
# because otherwise the .chezmoiroot file will be honored.

red() {
  printf "\033[0;31m%s\033[0m\n" "$*" >&2
}

error() {
  red "$*"
  exit 1
}

error "
⚠️ Detected old chezmoi version

❌ Manual action needed. To continue, please run:

👉 brew upgrade chezmoi && chezmoi init --apply
"
