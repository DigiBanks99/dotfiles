#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing Visual Studio Code..."

# Add Microsoft GPG key
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

# Add VS Code apt repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y code
