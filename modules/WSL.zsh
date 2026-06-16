#!/usr/bin/env zsh

source "$DOTFILES_HOME/modules/modules.zsh"

export MY_MOUDLES=(
    'zsh'
    'dotnet'
    'mise'
    'agents'
    'podman'
    'oh-my-posh'
)

export DOTFILES_MODULES=("${DOTFILES_MODULES[@]}" "${MY_MOUDLES[@]}")
