#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Updating Podman..."
sudo apt-get update -y || { log_warn "apt-get update failed; continuing"; }
sudo apt-get install -y --only-upgrade podman
