#!/usr/bin/env bash

set -euo pipefail

module_brew_bundle mise

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

log_info "Installing Node LTS via mise..."
mise use --global node@lts

# get shell name
SHELL_NAME="$(basename "$SHELL")"
log_debug "Current shell: $SHELL_NAME"
eval "$(mise activate $SHELL_NAME)"

log_info "Enabling pnpm via corepack..."
corepack enable pnpm

export PNPM_HOME="$HOME/.local"

log_info "Installing global npm packages..."
pnpm add -g rimraf prettier
