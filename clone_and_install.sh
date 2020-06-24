#!/bin/sh

set -eu

fancy_echo() {
    printf "\033[0;34m--> %s\n" "$1"
}

DOTFILES_USER=${1:-${DOTFILES_USER:-felipecassiors}}
DOTFILES_REPO="https://github.com/$DOTFILES_USER/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    fancy_echo "Removing $DOTFILES_DIR"
    rm -rf "$DOTFILES_DIR"
fi

fancy_echo "Cloning $DOTFILES_REPO to $DOTFILES_DIR"
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

INSTALL_BIN="$DOTFILES_DIR/install"
fancy_echo "Running $INSTALL_BIN"
exec "$INSTALL_BIN"
