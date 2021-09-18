#!/bin/bash

# This script is here for handling the migration of:
#   .chezmoi.toml.tmpl -> chezmoi.yaml.tmpl
#   dotfiles/          -> dotfiles/home/

error() {
  printf "\033[0;31m%s\033[0m\n" "$*" >&2
  exit 1
}

set -euo pipefail

migrated=false

# Read source-path before we actually delete the config
readonly chezmoi_source_path="$(chezmoi source-path)"

if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
  echo "Detected old chezmoi configuration file. Deleting it..."
  rm -f "$HOME/.config/chezmoi/chezmoi.toml"
  migrated=true
fi

if [[ "$chezmoi_source_path" != */home ]]; then
  echo "Detected old source path in the chezmoi configuration. Deleting whole configuration..."
  rm -f "$HOME/.config/chezmoi/chezmoi.yaml"
  migrated=true
fi

if [[ "$migrated" == true ]]; then
  error "
ERROR - Manual action needed. To continue, please run:

  chezmoi init --verbose --apply --force --source '$chezmoi_source_path/home'
"
fi
