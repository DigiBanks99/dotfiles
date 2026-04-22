#!/usr/bin/env bash

source "$DOTFILES_BIN/functions.sh"

log_info "Using profile: ${DOTFILES_PROFILE_NAME:-}"

log_debug "Loading base modules..."
base_modules=('git' 'base-cli' 'vscode' 'podman')
log_debug "Base modules: ${base_modules[*]}"

log_debug "Loading profile modules..."
modules_folder="$(dirname "${BASH_SOURCE[0]}")"
profile_modules_file="$modules_folder/$DOTFILES_PROFILE_NAME.sh"

if [[ ! -f "$profile_modules_file" ]]; then
    log_error "Profile modules file not found: $profile_modules_file"
    exit 1
fi

mapfile -t profile_modules < <(bash "$profile_modules_file")
log_debug "Profile modules: ${profile_modules[*]}"

for m in "${base_modules[@]}"; do echo "$m"; done
for m in "${profile_modules[@]}"; do echo "$m"; done
