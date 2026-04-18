#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update Ollama
echo "[INF]: Updating Ollama..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew upgrade ollama 2>/dev/null || true
elif command -v apt-get &>/dev/null || command -v snap &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "[WARN]: No supported package manager found. Update Ollama manually from https://ollama.com"
fi

# Update GitHub Copilot CLI
echo "[INF]: Updating GitHub Copilot CLI..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew upgrade gh 2>/dev/null || true
    gh extension upgrade github/gh-copilot 2>/dev/null || true
elif command -v apt-get &>/dev/null || command -v snap &>/dev/null; then
    gh extension upgrade github/gh-copilot 2>/dev/null || true
else
    echo "[WARN]: No supported package manager found. Update GitHub Copilot CLI manually."
fi

echo "[INF]: Refreshing agents module..."
bash "$SCRIPT_DIR/setup.sh"
