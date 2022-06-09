#!/bin/sh

set -eu

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_manual_action() {
  log_red "⚠️" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

sudo() {
  # shellcheck disable=SC2312
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif ! command sudo --non-interactive true 2>/dev/null; then
    log_manual_action "Root privileges are required, please enter your password below"
    command sudo --validate
  fi
  command sudo "$@"
}

get_default_branch() {
  path=$1
  git -C "${path}" remote show origin | grep 'HEAD branch' | cut -d' ' -f5
}

git_clean() {
  path=$(realpath "$1")
  branch="$(get_default_branch "${path}")"
  log_task "Cleaning ${path} with branch ${branch}"
  git="git -C ${path}"
  ${git} checkout "${branch}"
  ${git} fetch origin "${branch}"
  ${git} reset --hard FETCH_HEAD
  ${git} clean -fdx
  unset path
  unset branch
  unset git
}

DOTFILES_REPO_HOST=${DOTFILES_REPO_HOST:-"https://github.com"}
DOTFILES_USER=${DOTFILES_USER:-"felipecrs"}
DOTFILES_REPO="${DOTFILES_REPO_HOST}/${DOTFILES_USER}/dotfiles"
DOTFILES_BRANCH=${DOTFILES_BRANCH:-"master"}
DOTFILES_DIR="${HOME}/.dotfiles"

if ! command -v git >/dev/null 2>&1; then
  log_task "Installing git"
  sudo apt update
  sudo apt install git --yes
fi

if [ -d "${DOTFILES_DIR}" ]; then
  git_clean "${DOTFILES_DIR}"
else
  log_task "Cloning ${DOTFILES_REPO} on branch ${DOTFILES_BRANCH} to ${DOTFILES_DIR}"
  git clone -b "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

if [ -f "${DOTFILES_DIR}/install.sh" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
elif [ -f "${DOTFILES_DIR}/install" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install"
else
  error "No install script found in the dotfiles."
fi

log_task "Running ${INSTALL_SCRIPT}"
exec "${INSTALL_SCRIPT}"
