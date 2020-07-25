#!/usr/bin/env zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load .profile because of Homebrew and ~/bin.
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

# Enable Homebrew zsh completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

source "$HOME/.antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
  # Bundles from the default repo (robbyrussell's oh-my-zsh)
  git
  git-extras
  z
  docker
  docker-compose
  helm
  kubectl
  heroku
  pip
  lein
  npm
  node
  command-not-found
  common-aliases

  # Syntax highlighting bundle.
  zsh-users/zsh-syntax-highlighting

  # Fish-like auto suggestions
  zsh-users/zsh-autosuggestions

  # Extra zsh completions
  zsh-users/zsh-completions

  # Node Version Manager
  lukechilds/zsh-nvm
EOBUNDLES

# Load the theme.
# antigen theme denysdovhan/spaceship-prompt
antigen theme romkatv/powerlevel10k

# Tell Antigen that you're done.
antigen apply

### Fix for slowness of pastes
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### End of fix for slowness of pastes

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
