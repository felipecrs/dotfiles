# Felipe Santos' dotfiles

Bootstrap your Ubuntu in a single command!

![Sample dotfiles image](https://user-images.githubusercontent.com/29582865/173688885-acd1e312-4741-4ec1-bc9d-b1f31e289749.png)

This dotfiles repository is currently aimed for [**Ubuntu on WSL**](https://ubuntu.com/wsl), [**Ubuntu Server**](https://ubuntu.com/server), and [**Ubuntu Desktop**](https://ubuntu.com/desktop), tested against versions **18.04**, **20.04**, and **22.04**. See how to get started with WSL [here](https://docs.microsoft.com/pt-br/windows/wsl/install-win10).

It's also suitable for use in [**GitHub Codespaces**](https://docs.github.com/codespaces/customizing-your-codespace/personalizing-codespaces-for-your-account#dotfiles), [**Gitpod**](https://www.gitpod.io/docs/config-dotfiles), [**VS Code Remote - Containers**](https://code.visualstudio.com/docs/remote/containers#_personalizing-with-dotfile-repositories), or even Linux distribution that are not Ubuntu, through the [**minimum mode**](#minimum-mode).

Managed with [`chezmoi`](https://chezmoi.io), a great dotfiles manager.

## Getting started

You can use the [convenience script](./scripts/install_dotfiles.sh) to install the dotfiles on any machine with a single command. Simply run the following command in your terminal:

```bash
sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
```

> 💡 We use `wget` here because it comes preinstalled with most Ubuntu versions. But you can also use `curl`:
>
> ```bash
>  sh -c "$(curl -fsSL https://git.io/felipecrs-dotfiles)"
> ```

### Demo

https://user-images.githubusercontent.com/29582865/173691636-63a016b2-3e9b-49a4-bb7c-5514c28a77a3.mp4

### Minimum mode

The installation will ask if you want a **minimum mode installation**. The minimum mode only installs the needed dotfiles for the command prompt and is compatible with more distributions other than Ubuntu.

It will be enabled by default when running in a Dev Container or in distributions other than Ubuntu. For example, I use it in order to bring my environment to the [Home Assistant VS Code Add-on](https://github.com/hassio-addons/addon-vscode).

## Configuring the terminal font

This dotfiles uses the ZSH theme [Powerlevel10k](https://github.com/romkatv/powerlevel10k), so it requires you to install a font on your host machine with support for the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) glyphs. I recommend the [`FiraCode Nerd Font`](https://github.com/ryanoasis/nerd-fonts/tree/HEAD/patched-fonts/FiraCode#readme).

In **Ubuntu Desktop**, the dotfiles installation will take care of installing the font and set it up for you in **GNOME Terminal**.

But on other systems or terminal emulators, **you will need to configure it manually**. Here are some tips:

### Installing the font on **Windows**

1. [Download it by clicking here](https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf).
2. Open it and click in **_Install_**.
3. Restart any applications that you want to load the font into.

### Configuring the font in **VS Code**

1. On **VS Code**, press <kbd>Ctrl</kbd>+<kbd>,</kbd> to open the settings.
2. Search for "**Terminal Font Family**", and write `FiraCode Nerd Font` in the entry named **_Terminal › Integrated: Font Family_**. Like below:

   ![VS Code font configuration example](https://user-images.githubusercontent.com/29582865/112052025-5cb5aa80-8b31-11eb-8e85-a4eb9e1a09a8.png)

### Configuring the font in **Windows Terminal**

1. On **Windows Terminal**, press <kbd>Ctrl</kbd>+<kbd>,</kbd> to open the settings.
2. Go to **_Profiles -> Defaults_** in the left panel. Then, go to **_Additional settings -> Appearance_**.
3. At **_Text -> Font face_**, enable the **_Show all fonts_** option and select **_FiraCode Nerd Font_**. Like below:

   ![Windows Terminal font configuration example](https://user-images.githubusercontent.com/29582865/173674283-f6380d8c-a1ff-42b5-b963-ca578d09c2d5.png)

---

## Documentation

**If you followed the steps above so far, you already finished installing the dotfiles. Have fun!**

The below information is more for reference purposes.

### Convenience script

The [getting started](#getting-started) step used the [convenience script](./scripts/install_dotfiles.sh) to install this dotfiles. There are some extra options that you can use to tweak the installation if you need.

It supports some environment variables:

- `DOTFILES_REPO_HOST`: Defaults to `https://github.com`.
- `DOTFILES_USER`: Defaults to `felipecrs`.
- `DOTFILES_BRANCH`: Defaults to `master`.

For example, you can use it to clone and install the dotfiles repository at the `beta` branch with:

```console
DOTFILES_BRANCH=beta sh -c "$(wget -qO- https://git.io/felipecrs-dotfiles)"
```

### Installing without the convenience script

If you prefer not to use the convenience script to install the dotfiles, you can also do it manually:

```bash
git clone https://github.com/felipecrs/dotfiles "$HOME/.dotfiles"

"$HOME/.dotfiles/install.sh"
```

---

### Forking guide

If you are forking this repository, don't forget to change the following places:

- [`README.md`](./README.md)
  - Replace all occurrences of `https://git.io/felipecrs-dotfiles` with `https://raw.githubusercontent.com/<your-username>/dotfiles/HEAD/scripts/install_dotfiles.sh`
- [`scripts/install_dotfiles.sh`](./scripts/install_dotfiles.sh)
  - Replace all occurrences of `felipecrs` with `<your-username>`
- [`home/.chezmoi.yaml.tmpl`](./home/.chezmoi.yaml.tmpl)
  - Change the name and email to yours.

Where `<your-username>` is your GitHub username.

---

### Extra scripts

There are some scripts here to help you automate tricky activities when setting up your machine.

If you already have this dotfiles [installed](#getting-started), you can use these scripts right away. Or, if you want to run it without installing the dotfiles, you can do something like:

```bash
bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecrs/dotfiles/master/scripts/<script-name>")" -- <arguments>
```

Just replace `<script-name>` and `<arguments>` with the desired values. Example:

```bash
bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecrs/dotfiles/master/scripts/create_alternative_chrome_shortcut.sh")" -- --force
```

#### [`create_alternative_chrome_shortcut.sh`](scripts/create_alternative_chrome_shortcut.sh)

##### Usage

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

##### Examples

```bash
scripts/create_alternative_chrome_shortcut.sh Personal
```

##### Demo

![Opening two Chrome instances using different icons](./docs/images/create_alternative_chrome_shortcut.gif)
