#!/usr/bin/env bash

export DOTFILES_HOME=~/.dotfiles
export DOTFILES_BIN="$DOTFILES_HOME/bin"

source "$DOTFILES_BIN/functions.sh"

log_debug "Profile: ${DOTFILES_PROFILE_NAME:-}"
if [[ -z "${DOTFILES_PROFILE_NAME:-}" ]]; then
    log_debug "Profile not set. Resolving..."
    resolve_profile
fi

log_info "Loading $DOTFILES_PROFILE_NAME profile modules..."
source "$DOTFILES_HOME/modules/$DOTFILES_PROFILE_NAME.sh"

OS="$(get_os)"
log_debug "OS: $OS"
