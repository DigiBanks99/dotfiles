#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Updating Oh My Posh..."
curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
