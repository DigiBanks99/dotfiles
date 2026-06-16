#!/usr/bin/env bash

set -euo pipefail

PACKAGES=(
    build-essential
    gcc
    g++
    libicu-dev
    libssl-dev
    zlib1g-dev
)

log_info "Updating package lists..."
sudo apt-get update -y || { log_warn "apt-get update failed; continuing"; }

log_info "Installing base packages..."
sudo apt-get install -y "${PACKAGES[@]}"

module_brew_bundle base-cli

# Delegate to profile-specific setup if present
if [[ -n "${DOTFILES_PROFILE_NAME:-}" ]]; then
    profile_setup="$(dirname "$0")/$DOTFILES_PROFILE_NAME/setup.sh"
    if [[ -f "$profile_setup" ]]; then
        log_info "Running base-cli profile setup: $DOTFILES_PROFILE_NAME..."
        source "$profile_setup"
    fi
fi
