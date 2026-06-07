#!/usr/bin/env zsh

DIR=$(dirname "$0")

log_debug "Loading base modules..."
export DOTFILES_MODULES=('homebrew' 'git' 'base-cli' 'vscode' 'podman')
log_debug "Base modules: ${DOTFILES_MODULES[*]}"
