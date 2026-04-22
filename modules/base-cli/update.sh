#!/usr/bin/env bash

set -euo pipefail

PACKAGES=(
    bat
    curl
    git
    zip
    unzip
    coreutils
    jq
    openssl
    stow
    wget
    zsh
    zstd
)

echo "[INF]: Updating package index..."
    sudo apt-get update -y || { log_warn "apt-get update failed; continuing"; }

echo "[INF]: Upgrading base packages..."
sudo apt-get install -y --only-upgrade "${PACKAGES[@]}"

# Upgrade diff-so-fancy via npm if installed that way
if command -v npm &>/dev/null && command -v diff-so-fancy &>/dev/null; then
    echo "[INF]: Updating diff-so-fancy..."
    npm update -g diff-so-fancy 2>/dev/null || true
fi

# Delegate to profile-specific update if present
if [[ -n "${DOTFILES_PROFILE_NAME:-}" ]]; then
    profile_update="$(dirname "${BASH_SOURCE[0]}")/$DOTFILES_PROFILE_NAME/update.sh"
    if [[ -f "$profile_update" ]]; then
        echo "[INF]: Running base-cli profile update: $DOTFILES_PROFILE_NAME..."
        bash "$profile_update"
    fi
fi
