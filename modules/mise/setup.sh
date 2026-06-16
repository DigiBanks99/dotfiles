#!/usr/bin/env bash

set -euo pipefail

module_brew_bundle mise

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

log_info "Installing Node LTS via mise..."
mise use --global node@lts

log_debug "Current shell: bash"
eval "$(mise activate bash)"

log_info "Enabling pnpm via corepack..."
corepack enable pnpm

export PNPM_HOME="$HOME/.local"

log_info "Installing global npm packages..."
pnpm add -g rimraf prettier
