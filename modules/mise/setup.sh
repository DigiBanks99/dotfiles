#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing mise..."
curl https://mise.run | sh

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

echo "[INF]: Installing Node LTS via mise..."
mise use --global node@lts

echo "[INF]: Enabling pnpm via corepack..."
corepack enable pnpm

export PNPM_HOME="$HOME/.local/bin"

echo "[INF]: Installing global npm packages..."
pnpm add -g rimraf prettier
