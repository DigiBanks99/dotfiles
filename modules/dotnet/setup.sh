#!/usr/bin/env bash

set -euo pipefail

# Install dotnetup (user-level .NET toolchain manager)
DOTNETUP_HOME="$HOME/.dotnetup"
if [[ ! -x "$DOTNETUP_HOME/dotnetup" ]]; then
    echo "[INF]: Installing dotnetup..."
    curl -fsSL https://aka.ms/dotnetup/get-dotnetup.sh | bash
else
    echo "[INF]: dotnetup is already installed, skipping."
fi
export PATH="$DOTNETUP_HOME:$PATH"

echo "[INF]: Installing .NET SDKs with dotnetup..."
dotnetup install 8.0 10.0 --interactive false --no-progress

# Don't let dotnetup edit shell profiles; _zprofile.zsh activates it via `dotnetup env script`.
dotnetup env set none --dotnetup-on-path true
eval "$(dotnetup env script --shell bash --dotnet --dotnetup)"
export PATH="$HOME/.dotnet/tools:$PATH"

GLOBAL_TOOLS=(
    dotnet-ef
    dotnet-user-secrets
    security-scan
    dotnet-dev-certs
)

for tool in "${GLOBAL_TOOLS[@]}"; do
    echo "[INF]: Installing global .NET tool: $tool..."
    dotnet tool install -g "$tool" 2>/dev/null || dotnet tool update -g "$tool"
done

# Native AOT needs a native toolchain (clang on Linux, Xcode CLT on macOS)
if ! command -v clang >/dev/null 2>&1; then
    echo "[WRN]: clang not found; Native AOT publish will fail. Install clang (and zlib1g-dev on Debian/Ubuntu) or Xcode Command Line Tools."
fi

bash "$DOTFILES_HOME/modules/dotnet/run-single-executable.sh"
