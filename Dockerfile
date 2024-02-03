# syntax=docker/dockerfile:1.2

FROM mcr.microsoft.com/devcontainers/base:1-ubuntu-22.04

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

ENV USER="vscode"
ENV HOME="/home/${USER}"
ENV PATH="${HOME}/.local/bin:${PATH}"

USER "${USER}"
WORKDIR "${HOME}"

RUN --mount=type=bind,target=/tmp/dotfiles,rw \
  export DOTFILES_DOCKERFILE=true; \
  export DOTFILES_ONE_SHOT=true; \
  /tmp/dotfiles/install.sh; \
  sudo rm -rf /var/lib/apt/lists/*
