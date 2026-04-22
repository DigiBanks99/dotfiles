#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Updating git..."
sudo apt-get update -y
sudo apt-get install -y --only-upgrade git
