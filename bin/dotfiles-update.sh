#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/bootstrap.sh"

log_debug "Profile: ${DOTFILES_PROFILE_NAME:-}"
if [[ -z "${DOTFILES_PROFILE_NAME:-}" ]]; then
    log_debug "Profile not set. Resolving..."
    resolve_profile
fi
log_debug "Profile: $DOTFILES_PROFILE_NAME"

log_info "Reading profile modules..."
modules_folder="$DOTFILES_HOME/modules"
modules_file="$modules_folder/modules.sh"

if [[ ! -f "$modules_file" ]]; then
    log_error "Modules file not found: $modules_file"
    exit 1
fi

mapfile -t modules < <(bash "$modules_file")
log_debug "Modules: ${modules[*]}"

for module in "${modules[@]}"; do
    module_file="$modules_folder/$module/update.sh"
    if [[ -f "$module_file" ]]; then
        log_info "Updating module: $module..."
        bash "$module_file"
    else
        log_info "Skipping $module — no update.sh found."
    fi
done
