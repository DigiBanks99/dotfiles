#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

echo "[INF]: Upgrading mise tools..."
mise upgrade

echo "[INF]: Ensuring Node LTS is current..."
mise use --global node@lts

echo "[INF]: Updating global npm packages..."
export PNPM_HOME="$HOME/.local/bin"
pnpm update -g rimraf prettier
