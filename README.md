# Felipe Santos' dotfiles <!-- omit in toc -->

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/felipecrs/dotfiles)

Bootstrap your Ubuntu in a few minutes!

![Hello dotfiles! image](https://user-images.githubusercontent.com/29582865/112045407-95518600-8b29-11eb-8218-128fd2e9805a.png)

This dotfiles repository is currently aimed for [**Ubuntu on WSL**](https://ubuntu.com/wsl), **Ubuntu Server**, and **Ubuntu Desktop**, tested with **Ubuntu 18.04** and **Ubuntu 20.04**. See how to get started with WSL [here](https://docs.microsoft.com/pt-br/windows/wsl/install-win10). It's also suitable for use in [**GitHub Codespaces**](https://github.com/features/codespaces) and [**VS Code Remote - Containers**](https://code.visualstudio.com/docs/remote/containers).

This repository is managed with [`chezmoi`](https://chezmoi.io).

## Table of contents <!-- omit in toc -->

- [Get started](#get-started)
  - [1. Setup the font](#1-setup-the-font)
  - [2. Install the dotfiles](#2-install-the-dotfiles)
  - [Convenience script](#convenience-script)
  - [Install the dotfiles manually](#install-the-dotfiles-manually)
- [Forking guide](#forking-guide)
- [`scripts/`](#scripts)
  - [`create_alternative_chrome_shortcut.sh`](#create_alternative_chrome_shortcutsh)
    - [Usage](#usage)
    - [Examples](#examples)
    - [Demo](#demo)

---

## Get started

The current state of this dotfiles uses the zsh theme [Powerlevel10k](https://github.com/romkatv/powerlevel10k), so it requires you to install a font on your host machine with support for [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts). Currently I use `FiraCode Nerd Font`. You have to:

### 1. Setup the font

In Ubuntu Desktop, the dotfiles installation will take care of installing the font and set it up in GNOME Terminal. On Windows, you can install it with the following steps:

1. [Download it by clicking here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf).
2. Open it and click in _Install_.

Once you have it installed, you have to configure your terminal applications to use it. **To configure VS Code**:

> 💡 You need to restart both VS Code or Windows Terminal after installing the font before using it.

1. On VS Code, press `Ctrl`+`,` to open the settings.
2. Search for "Terminal Font Family", and write `FiraCode Nerd Font` in the entry named _Terminal › Integrated: Font Family_. Like below:

   ![VS Code font configuration](https://user-images.githubusercontent.com/29582865/112052025-5cb5aa80-8b31-11eb-8e85-a4eb9e1a09a8.png)

**To configure Windows Terminal**:

1. On Windows Terminal, press `Ctrl`+`,` to open the settings.
2. Click in _Open JSON file_ in the bottom left side. It will open the `settings.json` file in your text editor.
3. Insert a new `fontFace` key under `profiles.defaults` with the value `FiraCode Nerd Font`, something like:

   ```json
   {
     "profiles": {
       "defaults": {
         // Put settings here that you want to apply to all profiles.
         "fontFace": "FiraCode Nerd Font"
       }
     }
   }
   ```

**Now you are ready to install the dotfiles.**

### 2. Install the dotfiles

You can use the [convenience script](./clone_and_install.sh) to install the dotfiles pretty quickly, and it will install Git in case you don't have it already. Simply run the following command in your terminal:

```bash
sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
```

> 💡 We use `wget` here because it comes preinstalled with most of the Ubuntu versions. But you can also use `curl`:
>
> ```bash
>  sh -c "$(curl -fsSL https://git.io/felipecrs-dotfiles)"
> ```

**If you followed these steps so far, that means you finished installing the dotfiles already. Have fun!**

---

### Convenience script

The previous step used the [convenience script](./clone_and_install.sh) to install this dotfiles. There are some extra options that you can use to tweak the installation if you need.

The convenience script supports some environment variables:

- `DOTFILES_REPO_HOST`: Default to `https://github.com`.
- `DOTFILES_USER`: Default to `felipecrs`.
- `DOTFILES_BRANCH`: Default to `master`.

For example, you can use it to clone the dotfiles repository on branch `beta` with:

```bash
DOTFILES_BRANCH=beta sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
```

### Install the dotfiles manually

If you prefer not to use the convenience script to install the dotfiles, you can also do it manually:

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

---

## [`scripts/`](scripts/)

There are some scripts here to help you automate tricky activities when setting up your computer.

If you already have this dotfiles [installed](#get-started), you can use the scripts right away. Or, if you want to run it without installing the dotfiles, you can use something like:

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
