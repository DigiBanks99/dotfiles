#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_CONFIG="$SCRIPT_DIR"

link_file() {
    local src="$1"
    local dest="$2"
    # Re-create symlink if it's missing or points to the wrong target
    if [[ "$(readlink "$dest" 2>/dev/null)" != "$src" ]]; then
        rm -f "$dest"
        ln -sf "$src" "$dest"
        echo "[INF]: Updated link $dest -> $src"
    else
        echo "[INF]: Link already up-to-date: $dest"
    fi
}

link_file "$MODULE_CONFIG/.zshrc"    "$HOME/.zshrc"
link_file "$MODULE_CONFIG/.zprofile" "$HOME/.zprofile"
