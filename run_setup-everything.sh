#!/usr/bin/env bash

echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$@"
}

set -euo pipefail

if ! sudo -n true 2>/dev/null; then
  echo_task "Prompting for sudo password"
  sudo true
fi

echo_task "Adding user to sudoers"
echo "$USER  ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER"

echo_task "Installing Zsh"
sudo apt update && sudo apt install zsh -y

echo_task "Installing antigen"
function git_clean() {
  echo "Cleaning $(realpath "$1")"
  cd "$1"
  git fetch origin master
  git reset --hard FETCH_HEAD
  git clean -fdx
  cd - >/dev/null
}
antigen_dir="$HOME/.antigen"
if [ ! -d "$antigen_dir" ]; then
  git clone https://github.com/zsh-users/antigen.git "$antigen_dir"
else
  cd "$antigen_dir"
  git_clean .
  for bundle in bundles/*; do
    if [ -d "$bundle" ]; then
      git_clean "$bundle"
    fi
  done
  cd - >/dev/null
fi
unset antigen_dir

echo_task "Making zsh the default shell"
sudo chsh -s "$(which zsh)" "$USER"

echo_task "Installing Homebrew dependencies"
sudo apt install build-essential curl file -y

echo_task "Installing Homebrew"
CI=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
set +euo pipefail
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi
set -euo pipefail

echo_task "Sourcing .zshrc to initialize antigen"
zsh -c "source '$HOME/.zshrc' && antigen cleanup && antigen update"

echo_task "Installing gh, shellcheck, jq, chezmoi"
brew install gh shellcheck jq yq chezmoi

if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$IS_WSL" ]; then
  echo_task "Syncing .ssh folder from Windows to WSL"
  USERPROFILE="$(wslpath "$(wslvar USERPROFILE)")"
  if [ -f "$USERPROFILE/.ssh/id_rsa" ]; then
    cp -rf "$USERPROFILE/.ssh/." "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/id_rsa"
  else
    echo "No keys to sync"
  fi
  unset USERPROFILE
fi
