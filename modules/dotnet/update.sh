#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.dotnetup:$PATH"

echo "[INF]: Updating dotnetup and .NET SDKs..."
dotnetup self update
dotnetup update --interactive false --no-progress
eval "$(dotnetup env script --shell bash --dotnet --dotnetup)"
export PATH="$HOME/.dotnet/tools:$PATH"

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
