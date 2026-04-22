#!/usr/bin/env bash

set -euo pipefail

install_dotnet_sdk() {
    local version="$1"
    echo "[INF]: Updating .NET SDK $version..."
    curl -fsSL https://dot.net/v1/dotnet-install.sh | \
        bash -s -- --channel "$version" --install-dir "$HOME/.dotnet"
}

install_dotnet_sdk "8.0"
install_dotnet_sdk "9.0"

export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

GLOBAL_TOOLS=(
    dotnet-ef
    dotnet-user-secrets
    security-scan
    dotnet-dev-certs
)

for tool in "${GLOBAL_TOOLS[@]}"; do
    echo "[INF]: Updating global .NET tool: $tool..."
    dotnet tool update -g "$tool"
done
