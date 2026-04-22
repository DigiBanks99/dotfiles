#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_CONFIG="$SCRIPT_DIR"

link_file() {
    local src="$1"
    local dest="$2"
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -f "$dest"
    fi
    ln -sf "$src" "$dest"
    echo "[INF]: Linked $dest -> $src"
}

link_file "$MODULE_CONFIG/.zshrc"   "$HOME/.zshrc"
link_file "$MODULE_CONFIG/.zprofile" "$HOME/.zprofile"

# Set zsh as the default login shell
ZSH_PATH="$(which zsh)"
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "[INF]: Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi
echo "[INF]: Setting default shell to zsh..."
chsh -s "$ZSH_PATH"
