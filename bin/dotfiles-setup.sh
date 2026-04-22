#!/usr/bin/env bash

set -euo pipefail

DOTFILES_LOG_LEVEL="DEBUG"

echo "Setting up dotfiles..."
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/bootstrap.sh"

log_info "Loading profile..."
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

repair_apt_microsoft_vscode_repo_conflict() {
    local keyring="/usr/share/keyrings/microsoft-archive-keyring.gpg"

    log_info "Running apt sources preflight..."

    # Align old keyring paths to a single canonical path used by this repo.
    sudo sed -i.bak -E "s|/usr/share/keyrings/microsoft(\.gpg)?|${keyring}|g" \
        /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null || true

    # Keep only one VS Code repo definition to avoid duplicate Signed-By values.
    if [[ -f /etc/apt/sources.list.d/vscode.sources ]]; then
        sudo rm -f /etc/apt/sources.list.d/vscode.sources
    fi

    if [[ -f /etc/apt/sources.list.d/vscode.list ]]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] https://packages.microsoft.com/repos/code stable main" | \
            sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    fi
}

if [[ "$package_manager" == "apt-get" ]]; then
    repair_apt_microsoft_vscode_repo_conflict
fi

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
        bash -c "source \"$DOTFILES_BIN/functions.sh\" && source \"$module_file\""
    else
        log_warn "Skipping $module — no setup.sh found."
    fi
done
