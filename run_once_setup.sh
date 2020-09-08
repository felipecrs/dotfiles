#!/usr/bin/env bash

function echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$@"
}

function echo_sub_task() {
  printf "\033[0;34m----> %s\033[0m\n" "$@"
}

function is_wsl() {
  if [ -n "${WSL_DISTRO_NAME+x}" ] || [ -n "${IS_WSL+x}" ]; then
    return 0
  else
    return 1
  fi
}

function is_devcontainer() {
  # This is the way to go until we have something better
  # See: https://github.com/microsoft/vscode-dev-containers/issues/491
  if [ -n "${VSCODE_REMOTE_CONTAINERS_SESSION+x}" ] || [ -n "${CODESPACES+x}" ]; then
    return 0
  else
    return 1
  fi
}

function is_ubuntu() {
  local version=${1-'20.04'}

  if [[ "$(cat /etc/os-release)" = *VERSION_ID=\"$version\"* ]]; then
    return 0
  else
    return 1
  fi
}

function is_gnome() {
  # This is not the best way of doing it, but at least it works inside the
  # Visual Studio Code integrated terminal, which is enough for me now.
  if [ "$(command -v gnome-shell)" ]; then
    return 0
  else
    return 1
  fi
}

function brew() {
  bash <<EOM
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -f "\$HOME/.linuxbrew/bin/brew" ]; then
    eval "\$("\$HOME/.linuxbrew/bin/brew" shellenv)"
  else
    echo "Homebrew is not installed." >&2
    exit 1
  fi
  brew $@
EOM
}

function sdk() {
  bash <<EOM
  if [ -f "\$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    export SDKMAN_DIR="\$HOME/.sdkman"
    . "\$HOME/.sdkman/bin/sdkman-init.sh"
  else
    echo "SDKMAN! is not installed." >&2
    exit 1
  fi
  sdk $@
EOM
}

set -euo pipefail

# See: https://github.com/microsoft/vscode-remote-release/issues/3531#issuecomment-675278804
if [ -z "${USER+x}" ]; then
  USER="$(id -un)"
fi

if ! sudo -n true 2>/dev/null; then
  echo_task "Prompting for sudo password"
  sudo true
fi

echo_task "Adding user to sudoers"
echo "$USER  ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER"

echo_task "Installing ZSH"
if ! zsh --version &>/dev/null; then
  sudo apt update
  sudo apt install -y zsh
else
  echo "ZSH already installed"
fi

echo_task "Making zsh the default shell"
sudo chsh -s "$(which zsh)" "$USER"

echo_task "Initializing ZSH (with Antigen and Powerlevel10k)"
zsh -is <<<'' 2>/dev/null

if ! is_devcontainer; then
  echo_task "Updating APT lists"
  sudo apt update

  echo_task "Installing Homebrew"
  if ! brew --version &>/dev/null; then
    sudo apt install build-essential curl file -y
    CI=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    echo "Homebrew is already installed."
  fi

  echo_task "Installing Homebrew bundle"
  brew bundle install --global

  # Uninstalling previously installed chezmoi because it was already installed
  # by brew.
  local_bin_chezmoi="$HOME/.local/bin/chezmoi"
  if [ -f "$local_bin_chezmoi" ]; then
    echo_task "Uninstalling chezmoi at $local_bin_chezmoi"
    rm -f "$local_bin_chezmoi"
  fi
  unset local_bin_chezmoi

  echo_task "Installing SDKMAN!"
  if ! sdk version &>/dev/null; then
    sudo apt install -y zip
    bash -c "$(curl -fsSL "https://get.sdkman.io/?rcupdate=false")"
  else
    echo "SDKMAN! is already installed."
  fi

  echo_task "Installing Java 8"
  # get the identifier for java 8
  identifier="$(sdk ls java | grep -m 1 -o ' 8.*.hs-adpt ' | awk '{print $NF}')"
  # ignore SDKMAN! error because often it's just already installed, at least
  # until https://github.com/sdkman/sdkman-cli/pull/777 does not get merged.
  sdk i java "$identifier" || true
  unset identifier

  if is_wsl; then
    echo_task "Performing WSL specific steps"

    echo_task "Syncing .ssh folder from Windows to WSL"
    USERPROFILE="$(wslpath "$(wslvar USERPROFILE)")"
    if [ -f "$USERPROFILE/.ssh/id_rsa" ]; then
      cp -rf "$USERPROFILE/.ssh/." "$HOME/.ssh"
      chmod 600 "$HOME/.ssh/id_rsa"
    else
      echo "No keys to sync"
    fi
    unset USERPROFILE
  else
    echo_task "Performing NOT WSL specific steps"

    echo_task "Setting up Git credential helper to Gnome keyring"
    sudo apt update
    sudo apt install -y libsecret-1-0 libsecret-1-dev
    sudo make --directory /usr/share/doc/git/contrib/credential/libsecret

    if is_gnome; then
      echo_task "Adding 'Open Code here' in Nautilus context menu"
      bash -c "$(wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh)"

      if is_ubuntu 20.04; then
        echo_task "Setting up dark theme"
        sudo apt install -y gnome-shell-extensions
        gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
        gsettings set org.gnome.desktop.interface gtk-theme "Yaru-dark"
        gsettings set org.gnome.shell.extensions.user-theme name "Yaru-dark"
      fi
    fi
  fi
fi
