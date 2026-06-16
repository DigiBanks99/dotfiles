#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_CONFIG="$SCRIPT_DIR/.config"

# Install GitHub Copilot CLI
log_info "Installing GitHub Copilot CLI..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask github-copilot-for-xcode 2>/dev/null || \
        brew install gh && gh extension install github/gh-copilot 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    gh extension install github/gh-copilot 2>/dev/null || true
elif command -v snap &>/dev/null; then
    sudo snap install gh && gh extension install github/gh-copilot 2>/dev/null || true
else
    log_warn "No supported package manager found for GitHub Copilot CLI. Install manually."
fi

# Symlink .agents
log_info "Linking ~/.agents..."
if [ -e "$HOME/.agents" ] || [ -L "$HOME/.agents" ]; then
    rm -rf "$HOME/.agents"
fi
ln -sf "$MODULE_CONFIG/.agents" "$HOME/.agents"

# Symlink .copilot
log_info "Linking ~/.copilot..."
if [ -e "$HOME/.copilot" ] || [ -L "$HOME/.copilot" ]; then
    rm -rf "$HOME/.copilot"
fi
ln -sf "$MODULE_CONFIG/.copilot" "$HOME/.copilot"

# Generate config.json from template
log_info "Generating ~/.copilot/config.json from template..."
TEMPLATE="$MODULE_CONFIG/config.template.json"
CONFIG="$MODULE_CONFIG/.copilot/config.json"
sed "s|{{USERPROFILE}}|$HOME|g" "$TEMPLATE" > "$CONFIG"

log_info "Done. ~/.agents and ~/.copilot are ready."
