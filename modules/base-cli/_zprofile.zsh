#!/usr/bin/env zsh
# Ensure system /etc/zsh/zshrc can safely reference this variable
export skip_global_compinit=1

# Export basic dotfiles vars used by other profile scripts
export DOTFILES_HOME="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES_HOME/bin"
