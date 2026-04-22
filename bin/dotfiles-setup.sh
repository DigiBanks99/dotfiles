#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/bootstrap.sh"

resolve_package_manager() {
    log_info "Resolving package manager..."
    if [[ "$OS" == "Darwin" ]]; then
        check_command brew || { log_error "Homebrew is not installed."; exit 1; }
        echo "brew"
    elif [[ "$OS" == "windows" ]]; then
        check_command winget || { log_error "winget not found."; exit 1; }
        echo "winget"
    else
        resolve_distro
        get_package_manager
    fi
}

log_debug "Profile: ${DOTFILES_PROFILE_NAME:-}"
if [[ -z "${DOTFILES_PROFILE_NAME:-}" ]]; then
    log_debug "Profile not set. Resolving..."
    resolve_profile
fi
log_debug "Profile: $DOTFILES_PROFILE_NAME"

package_manager="$(resolve_package_manager)"
log_debug "Package manager: $package_manager"

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
    module_file="$modules_folder/$module/setup.sh"
    if [[ -f "$module_file" ]]; then
        log_info "Installing module: $module..."
        bash "$module_file"
    else
        log_warn "Skipping $module — no setup.sh found."
    fi
done
