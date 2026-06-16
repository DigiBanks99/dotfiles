#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing Visual Studio Code..."

# Add Microsoft GPG key and ensure consistent Signed-By usage
KEYRING="/usr/share/keyrings/microsoft-archive-keyring.gpg"
TMP_KEY="$(mktemp)"

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc -o "$TMP_KEY"
if [[ -s "$TMP_KEY" ]]; then
    gpg --dearmor < "$TMP_KEY" >"${TMP_KEY}.gpg" || true
    sudo mv -f "${TMP_KEY}.gpg" "$KEYRING" || true
    rm -f "$TMP_KEY"
fi

# Normalize any existing sources to use the chosen keyring to avoid Signed-By conflicts
sudo sed -i.bak -E "s|/usr/share/keyrings/microsoft(\.gpg)?|${KEYRING}|g" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/vscode.sources

# Add VS Code apt repository (signed-by points at our canonical keyring)
echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING}] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt-get update -y || { log_warn "apt-get update failed; continuing"; }
sudo apt-get install -y code || { log_warn "Failed to install code via apt; please inspect sources."; }
