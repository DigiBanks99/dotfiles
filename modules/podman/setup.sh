#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing Podman..."

# Add the official Podman apt repository for Ubuntu when available
UBUNTU_VERSION_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
ARCH="$(dpkg --print-architecture)"
REPO_BASE="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable"
REPO_URL="$REPO_BASE/xUbuntu_${UBUNTU_VERSION_CODENAME}"

if curl -fsSL "${REPO_URL}/Release.key" >/dev/null 2>&1; then
    echo "deb [arch=${ARCH}] ${REPO_URL}/ /" | sudo tee /etc/apt/sources.list.d/podman.list > /dev/null
    curl -fsSL "${REPO_URL}/Release.key" | sudo gpg --dearmor -o /usr/share/keyrings/podman-archive-keyring.gpg
    sudo sed -i 's|deb \[arch|deb [signed-by=/usr/share/keyrings/podman-archive-keyring.gpg] [arch|' \
        /etc/apt/sources.list.d/podman.list
    sudo apt-get update -y
    sudo apt-get install -y podman
else
    echo "[WARN]: Podman repository not available for '${UBUNTU_VERSION_CODENAME}'. Falling back to distro packages."
    sudo apt-get update -y || true
    sudo apt-get install -y podman || echo "[WARN]: podman not available in distro repos; skipping."
fi
