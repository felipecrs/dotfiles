#!/bin/sh

set -eu

DOTFILES_REPO="${1:-https://github.com/felipecassiors/dotfiles}"
DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    echo "--> Removing $DOTFILES_DIR"
    rm -rf "$DOTFILES_DIR"
fi

echo "--> Cloning $DOTFILES_REPO to $DOTFILES_DIR"
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

INSTALL_BIN="$DOTFILES_DIR/install"
echo "--> Running $INSTALL_BIN"
exec "$INSTALL_BIN"
