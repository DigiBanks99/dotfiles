#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Updating Visual Studio Code..."
sudo apt-get update -y
sudo apt-get install -y --only-upgrade code
