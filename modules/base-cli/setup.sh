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
)

echo "[INF]: Updating package index..."
sudo apt-get update -y

echo "[INF]: Installing base packages..."
sudo apt-get install -y "${PACKAGES[@]}"

# diff-so-fancy is not always in the default Ubuntu apt repos; install via npm if available
if ! command -v diff-so-fancy &>/dev/null; then
    if command -v npm &>/dev/null; then
        echo "[INF]: Installing diff-so-fancy via npm..."
        npm install -g diff-so-fancy 2>/dev/null || true
    else
        echo "[WARN]: diff-so-fancy not available via apt and npm is not installed. Skipping."
    fi
fi

# Delegate to profile-specific setup if present
if [[ -n "${DOTFILES_PROFILE_NAME:-}" ]]; then
    profile_setup="$(dirname "${BASH_SOURCE[0]}")/$DOTFILES_PROFILE_NAME/setup.sh"
    if [[ -f "$profile_setup" ]]; then
        echo "[INF]: Running base-cli profile setup: $DOTFILES_PROFILE_NAME..."
        bash "$profile_setup"
    fi
fi
