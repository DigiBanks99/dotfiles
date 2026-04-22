#!/usr/bin/env bash

set -euo pipefail

echo "[INF]: Installing git..."
sudo apt-get update -y || { log_warn "apt-get update failed; continuing"; }
sudo apt-get install -y git
