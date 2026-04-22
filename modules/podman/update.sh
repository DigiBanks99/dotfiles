#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Updating Podman..."
sudo apt-get update -y
sudo apt-get install -y --only-upgrade podman
