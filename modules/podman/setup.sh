#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing Podman..."

# Add the official Podman apt repository for Ubuntu
UBUNTU_VERSION="$(. /etc/os-release && echo "$VERSION_CODENAME")"

echo "deb [arch=$(dpkg --print-architecture)] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${UBUNTU_VERSION}/ /" | \
    sudo tee /etc/apt/sources.list.d/podman.list > /dev/null

curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${UBUNTU_VERSION}/Release.key" | \
    sudo gpg --dearmor -o /usr/share/keyrings/podman-archive-keyring.gpg

sudo sed -i 's|deb \[arch|deb [signed-by=/usr/share/keyrings/podman-archive-keyring.gpg] [arch|' \
    /etc/apt/sources.list.d/podman.list

sudo apt-get update -y
sudo apt-get install -y podman
