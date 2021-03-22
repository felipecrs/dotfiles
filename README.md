# Felipe Santos' dotfiles <!-- omit in toc -->

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/felipecrs/dotfiles#scripts)

Bootstrap your Ubuntu in a few minutes!

<p align="center">
  <img src="https://user-images.githubusercontent.com/29582865/112045407-95518600-8b29-11eb-8218-128fd2e9805a.png" alt="Hello dotfiles!"/>
</p>

This dotfiles repository is currently aimed for [**Ubuntu on WSL**](https://ubuntu.com/wsl), **Ubuntu Server**, and **Ubuntu Desktop**, tested with **Ubuntu 20.04**. See how to get started with WSL [here](https://docs.microsoft.com/pt-br/windows/wsl/install-win10). It's also suitable for use in [**GitHub Codespaces**](https://github.com/features/codespaces) and [**VS Code Remote - Containers**](https://code.visualstudio.com/docs/remote/containers).

This repository is managed with [`chezmoi`](https://chezmoi.io).

## Summary <!-- omit in toc -->

- [Get started](#get-started)
  - [Setup the font](#setup-the-font)
  - [Install](#install)
    - [Usage](#usage)
    - [Examples](#examples)
  - [Install manually](#install-manually)
- [Forking guide](#forking-guide)
- [`scripts/`](#scripts)
  - [`create_alternative_chrome_shortcut.sh`](#create_alternative_chrome_shortcutsh)
    - [Usage](#usage-1)
    - [Examples](#examples-1)
    - [Demo](#demo)

## Get started

The current state of this dotfiles uses the zsh theme [Powerlevel10k](https://github.com/romkatv/powerlevel10k), so it requires you to install a font on your host machine with support for [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts). Currently I use `FiraCode Nerd Font`. You have to:

1. [Setup the font](#set-up-the-font)
2. [Install the dotfiles](#installing)

### Setup the font

In Ubuntu Desktop, the dotfiles installation will take care of installing the font and set it up in GNOME Terminal. On Windows, you can install it with the following steps:

1. [Download it by clicking here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf).
2. Open it and click in _Install_.

Once you have it installed, you have to configure your terminal applications to use it. **To configure VS Code**:

1. On VS Code, press `Ctrl`+`,` to open the settings.
2. Search by "Terminal Font Family" and write `FiraCode Nerd Font` under _Terminal › Integrated: Font Family_.

**To configure Windows Terminal**:

1. On Windows Terminal, press `Ctrl`+`,` to open the settings. It will open a `json` file in your text editor.
2. Insert a new `fontFace` key under `profiles.defaults` with the value `FiraCode Nerd Font`, something like:

   ```json
   {
     "profiles": {
       "defaults": {
         "fontFace": "FiraCode Nerd Font"
       }
     }
   }
   ```

Note that both applications needs to be restarted after installing the font before using it.

Now you will learn how to bootstrap this repository on your machine.

### Install

You can use the [convenience script](./clone_and_install.sh) to get started pretty quick, it will install Git in case you don't have it already:

```bash
sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
```

> 💡 We use `wget` here because not all systems comes with `curl` installed. But the `curl` version of it is:
>
> ```bash
>  sh -c "$(curl -fsSL https://git.io/felipecrs-dotfiles)"
> ```

#### Usage

The convenience script supports some environment variables:

- `DOTFILES_REPO_HOST`: Default to `https://github.com`.
- `DOTFILES_USER`: Default to `felipecrs`.
- `DOTFILES_BRANCH`: Default to `master`.

#### Examples

- Using the convenience script to clone the dotfiles repository on branch `beta`:

  ```bash
  DOTFILES_BRANCH=beta sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
  ```

### Install manually

You can also do it manually, without the convenience script, it's simple after all.

```bash
git clone https://github.com/felipecrs/dotfiles "$HOME/.dotfiles"
"$HOME/.dotfiles/install"
```

## Forking guide

If you are forking this repository, you'll have to edit the following areas:

- [`README.md`](./README.md)
  - Change `https://git.io/felipecrs-dotfiles` to `https://raw.githubusercontent.com/<your-username>/dotfiles/master/scripts/install_dotfiles.sh`
- [`scripts/install_dotfiles.sh`](./scripts/install_dotfiles.sh)
  - Change `felipecrs` to `<your-username>`
- [`.chezmoi.toml.tmpl`](./.chezmoi.toml.tmpl)
  - Change personal and work name and email to yours.

Where `<your-username>` is your GitHub username or organization name.

## [`scripts/`](scripts/)

If you already have this repository [bootstrapped](#get-started) in your machine, you can use the scripts right away. Or, if you want to run it directly, you can use:

```bash
bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecrs/dotfiles/master/scripts/<script-name>")" -- <arguments>
```

Just replace `<script-name>` and `<arguments>` with the desired values. Example:

```bash
bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecrs/dotfiles/master/scripts/create_alternative_chrome_shortcut.sh")" -- --force
```

### [`create_alternative_chrome_shortcut.sh`](scripts/create_alternative_chrome_shortcut.sh)

#### Usage

```sh-session
$ scripts/create_alternative_chrome_shortcut.sh --help
Usage: scripts/create_alternative_chrome_shortcut.sh [-f|--(no-)force] [-h|--help] [<display-name>]
        <display-name>: The name which will be displayed in the app launcher (default: 'Alternative')
        -f, --force, --no-force: Do not ask for confirmation (off by default)
        -h, --help: Prints help

This script creates a new shortcut for Google Chrome which opens using a
different user data directory. This lets you have different icons for different
instances of Google Chrome.

Please check the following URL for more information:
  https://github.com/felipecrs/dotfiles#create_alternative_chrome_shortcutsh
```

#### Examples

```bash
scripts/create_alternative_chrome_shortcut.sh Personal
```

#### Demo

![Opening two Chrome instances using different icons](./docs/images/create_alternative_chrome_shortcut.gif)
