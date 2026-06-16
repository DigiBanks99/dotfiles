#!/usr/bin/env bash

source "$DOTFILES_HOME/modules/modules.sh"

export MY_MOUDLES=(
    'dotnet'
    'oh-my-posh'
    'mise'
    'agents'
    'zsh'
)

export DOTFILES_MODULES=("${DOTFILES_MODULES[@]}" "${MY_MOUDLES[@]}")
