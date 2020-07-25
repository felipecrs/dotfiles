#!/bin/sh

set -eu

echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$@"
}

cd "$HOME"

DOTFILES_USER=${DOTFILES_USER:-felipecassiors}
DOTFILES_REPO="https://github.com/$DOTFILES_USER/dotfiles"
DOTFILES_BRANCH=${DOTFILES_BRANCH:-master}
DOTFILES_DIR="$HOME/.dotfiles"

if [ "$(command -v git)" ]; then
  echo "Git not found"
  if ! sudo -n true 2>/dev/null; then
    echo_task "Prompting for sudo password to install Git"
    sudo true
  fi
  echo_task "Installing Git"
  sudo apt update
  sudo apt install git -y
fi

if [ -d "$DOTFILES_DIR" ]; then
  echo_task "Cleaning existing $(realpath "$DOTFILES_DIR")"
  cd "$DOTFILES_DIR"
  git fetch origin "$DOTFILES_BRANCH"
  git reset --hard FETCH_HEAD
  git clean -fdx
  cd - >/dev/null
else
  echo_task "Cloning $DOTFILES_REPO on branch $DOTFILES_BRANCH to $DOTFILES_DIR"
  git clone -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

INSTALL_BIN="$DOTFILES_DIR/install"
echo_task "Running $INSTALL_BIN"
exec "$INSTALL_BIN"
