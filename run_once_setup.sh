#!/usr/bin/env bash

set -euo pipefail

echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$@"
}

echo_sub_task() {
  printf "\033[0;34m----> %s\033[0m\n" "$@"
}

is_wsl() {
  if [ -n "${WSL_DISTRO_NAME+x}" ] || [ -n "${IS_WSL+x}" ]; then
    return 0
  else
    return 1
  fi
}

is_devcontainer() {
  # VSCODE_REMOTE_CONTAINERS_SESSION:
  # https://github.com/microsoft/vscode-remote-release/issues/3517#issuecomment-698617749
  if [ -n "${REMOTE_CONTAINERS+x}" ] || [ -n "${CODESPACES+x}" ] || [ -n "${VSCODE_REMOTE_CONTAINERS_SESSION+x}" ]; then
    return 0
  else
    return 1
  fi
}

is_ubuntu() {
  local version=${1-'20.04'}

  if [[ "$(cat /etc/os-release)" = *VERSION_ID=\"$version\"* ]]; then
    return 0
  else
    return 1
  fi
}

is_gnome() {
  # This is not the best way of doing it, but at least it works inside the
  # Visual Studio Code integrated terminal, which is enough for me now.
  if [ "$(command -v gnome-shell)" ]; then
    return 0
  else
    return 1
  fi
}

brew() {
  bash <<EOM
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -f "\$HOME/.linuxbrew/bin/brew" ]; then
    eval "\$("\$HOME/.linuxbrew/bin/brew" shellenv)"
  else
    echo "brew is not installed" >&2
    exit 127
  fi
  brew $@
EOM
}

nvm() {
  bash <<EOM
  export NVM_DIR="\$([ -z "\${XDG_CONFIG_HOME-}" ] && printf %s "\${HOME}/.nvm" || printf %s "\${XDG_CONFIG_HOME}/nvm")"
  if [ -f "\$NVM_DIR/nvm.sh" ]; then
    . "\$NVM_DIR/nvm.sh"
  else
    echo "nvm is not installed" >&2
    exit 127
  fi
  nvm $@
EOM
}

sdk() {
  bash <<EOM
  export SDKMAN_DIR="\$HOME/.sdkman"
  if [ -f "\$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    . "\$SDKMAN_DIR/bin/sdkman-init.sh"
  else
    echo "sdk is not installed" >&2
    exit 127
  fi
  sdk $@
EOM
}

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

echo_task "Installing zsh"
if ! zsh --version &>/dev/null; then
  sudo apt update
  sudo apt install -y zsh
else
  echo "zsh already installed"
fi

echo_task "Making zsh the default shell"
sudo chsh -s "$(which zsh)" "$USER"

echo_task "Initializing zsh"
(
  # We need to be in a git repository, so gitstatusd initiliazes
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  cd "$script_dir"
  # We also need to emulate a TTY
  script -qec "zsh -is </dev/null" /dev/null
)
echo "Done."

if ! is_devcontainer; then
  echo_task "Installing common packages"
  sudo apt update
  sudo apt install -y software-properties-common build-essential curl wget tree parallel file zip

  echo_task "Installing git"
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt install -y git

  echo_task "Installing skopeo"
  curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -sr)/Release.key" | sudo apt-key add -
  sudo add-apt-repository -y "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -sr)/ /"
  sudo apt install -y skopeo

  echo_task "Installing podman"
  sudo apt install -y podman

  echo_task "Installing buildah"
  sudo apt install -y buildah

  echo_task "Installing Helm"
  curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add -
  sudo add-apt-repository -y "deb https://baltocdn.com/helm/stable/debian/ all main"
  sudo apt install -y helm

  echo_task "Installing kubectl"
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo add-apt-repository -y "deb https://apt.kubernetes.io/ kubernetes-xenial main"
  sudo apt install -y kubectl

  echo_task "Installing yq"
  sudo add-apt-repository -y ppa:rmescandon/yq
  sudo apt install -y yq

  echo_task "Installing brew"
  if ! brew --version &>/dev/null; then
    CI=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    echo "brew is already installed"
  fi

  echo_task "Installing brew packages"
  brew bundle install --global

  # Uninstalling previously installed chezmoi because it was already installed
  # by Homebrew.
  local_bin_chezmoi="$HOME/.local/bin/chezmoi"
  if [ -f "$local_bin_chezmoi" ]; then
    echo_task "Uninstalling chezmoi at $local_bin_chezmoi"
    rm -f "$local_bin_chezmoi"
  fi
  unset local_bin_chezmoi

  echo_task "Installing deno"
  if ! deno --version &>/dev/null; then
    sh -c "$(curl -fsSL https://deno.land/x/install/install.sh)"
  else
    echo "deno is already installed"
  fi

  echo_task "Installing volta"
  bash -c "$(curl -fsSL https://get.volta.sh)" -- --skip-setup

  echo_task "Installing node"
  volta install node

  echo_task "Installing sdk"
  if ! sdk version &>/dev/null; then
    bash -c "$(curl -fsSL "https://get.sdkman.io/?rcupdate=false")"
  else
    echo "sdk is already installed"
  fi

  echo_task "Installing Java 8"
  # get the identifier for java 8
  identifier="$(sdk ls java | grep -m 1 -o ' 8.*.hs-adpt ' | awk '{print $NF}')"
  sdk i java "$identifier"
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

    echo_task "Setting up Git credential helper"
    sudo git config --system credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
  elif is_gnome; then
    echo_task "Performing GNOME specific steps"

    echo_task "Setting up Git credential helper"
    sudo apt install -y libsecret-1-0 libsecret-1-dev
    sudo make --directory /usr/share/doc/git/contrib/credential/libsecret
    sudo git config --system credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

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
