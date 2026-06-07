#!/usr/bin/env zsh

source "$DOTFILES_HOME/modules/modules.zsh"

export MY_MOUDLES=(
    'dotnet'
    'oh-my-posh'
    'mise'
    'agents'
)

export DOTFILES_MODULES=("${DOTFILES_MODULES[@]}" $MY_MOUDLES)
