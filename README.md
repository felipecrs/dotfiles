# Felipe Santos's dotfiles

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/felipecassiors/dotfiles)

Bootstrap your Ubuntu on WSL in less than five minutes!

![Convenience script](https://user-images.githubusercontent.com/29582865/85643227-e51e2200-b669-11ea-9cea-eb2e17c4dc19.gif)

This dotfiles repository is currently aimed for [Ubuntu on WSL](https://ubuntu.com/wsl). See how to get started with WSL [here](https://docs.microsoft.com/pt-br/windows/wsl/install-win10).

The current state of this dotfiles uses the zsh theme [Powerlevel10k](https://github.com/romkatv/powerlevel10k), so it requires you to install a font on your host machine with support for [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts). Currently I use `FiraCode NF`, and you can install it on Windows with [Chocolatey](https://chocolatey.org/install):

```powershell
choco install firacodenf
```

## Convenience script

You can use the [convenience script](./clone_and_install.sh) with:

```bash
sh -c "$(curl -fsSL https://git.io/felipe-dotfiles)"
```

### Environment variables

The convenience script supports two environment variables:

- `DOTFILES_REPO`: Default to `felipecassiors`.
- `DOTFILES_BRANCH`: Default to `master`.

#### Examples

- Using the convenience script to clone the dotfiles repository on branch `beta`:

  ```bash
  DOTFILES_BRANCH=beta sh -c "$(curl -fsSL https://git.io/felipe-dotfiles)"
  ```

## Manually

You can also do it manually, it's simple after all.

```bash
git clone https://github.com/felipecassiors/dotfiles "$HOME/.dotfiles"
"$HOME/.dotfiles/install"
```
