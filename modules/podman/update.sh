#!/usr/bin/env bash

set -euo pipefail

log_info "Updating Podman..."

latest_url="https://github.com/podman-container-tools/podman/releases/latest"
latest_version=$(curl -sL -o /dev/null -w '%{url_effective}' "$latest_url" | awk -F'/' '{print $NF}')
log_debug "Latest Podman version: $latest_version"
download_url="https://github.com/podman-container-tools/podman/releases/download/${latest_version}/podman-remote-static-linux_amd64.tar.gz"

log_debug "Download URL: $download_url"
wget "$download_url"
sudo tar -C /usr/local -xzf podman-remote-static-linux_amd64.tar.gz
rm podman-remote-static-linux_amd64.tar.gz