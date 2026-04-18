#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_CONFIG="$SCRIPT_DIR/.config"

# Install Ollama
echo "[INF]: Installing Ollama..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ollama 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
elif command -v snap &>/dev/null; then
    sudo snap install ollama 2>/dev/null || true
else
    echo "[WARN]: No supported package manager found for Ollama. Install manually from https://ollama.com"
fi

# Install GitHub Copilot CLI
echo "[INF]: Installing GitHub Copilot CLI..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask github-copilot-for-xcode 2>/dev/null || \
        brew install gh && gh extension install github/gh-copilot 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    gh extension install github/gh-copilot 2>/dev/null || true
elif command -v snap &>/dev/null; then
    sudo snap install gh && gh extension install github/gh-copilot 2>/dev/null || true
else
    echo "[WARN]: No supported package manager found for GitHub Copilot CLI. Install manually."
fi

# Symlink .agents
echo "[INF]: Linking ~/.agents..."
if [ -e "$HOME/.agents" ] || [ -L "$HOME/.agents" ]; then
    rm -rf "$HOME/.agents"
fi
ln -sf "$MODULE_CONFIG/.agents" "$HOME/.agents"

# Symlink .copilot
echo "[INF]: Linking ~/.copilot..."
if [ -e "$HOME/.copilot" ] || [ -L "$HOME/.copilot" ]; then
    rm -rf "$HOME/.copilot"
fi
ln -sf "$MODULE_CONFIG/.copilot" "$HOME/.copilot"

# Generate config.json from template
echo "[INF]: Generating ~/.copilot/config.json from template..."
TEMPLATE="$MODULE_CONFIG/config.template.json"
CONFIG="$MODULE_CONFIG/.copilot/config.json"
sed "s|{{USERPROFILE}}|$HOME|g" "$TEMPLATE" > "$CONFIG"

echo "[INF]: Done. ~/.agents and ~/.copilot are ready."
