# syntax=docker/dockerfile:1.2

FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

ENV USER="vscode"
ENV HOME="/home/${USER}"
ENV PATH="${HOME}/.local/bin:${PATH}"

ARG DEBIAN_FRONTEND="noninteractive"

USER "${USER}"
WORKDIR "${HOME}"

RUN --mount=type=bind,target=/tmp/dotfiles,rw \
  export DOTFILES_DOCKERFILE=true; \
  export DOTFILES_ONE_SHOT=true; \
  sh <(curl -fsSL https://git.io/chezmoi) init --one-shot --source /tmp/dotfiles; \
  sudo rm -rf /var/lib/apt/lists/*
