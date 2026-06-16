#!/usr/bin/env bash

source "$DOTFILES_BIN/functions.sh"
DIR=$(dirname "$0")

log_debug "Loading base modules..."
export DOTFILES_MODULES=('homebrew' 'git' 'base-cli')
log_debug "Base modules: ${DOTFILES_MODULES[*]}"
