#!/usr/bin/env bash

set -euo pipefail

source "$DOTFILES_BIN/functions.sh"

resolve_runtime_id() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os/$arch" in
        Darwin/arm64) echo "osx-arm64" ;;
        Darwin/x86_64) echo "osx-x64" ;;
        Linux/x86_64) echo "linux-x64" ;;
        Linux/aarch64|Linux/arm64) echo "linux-arm64" ;;
        *)
            log_error "Unsupported runtime for single-file publish: $os/$arch"
            return 1
            ;;
    esac
}

runtime_id="$(resolve_runtime_id)"
publish_dir="$DOTFILES_HOME/bin/Release/net8.0/$runtime_id/publish"
output_binary="$DOTFILES_BIN/dotfiles"

log_info "Publishing dotfiles single executable for runtime '$runtime_id'..."
dotnet publish "$DOTFILES_HOME/dotfiles.csproj" \
    -c Release \
    -r "$runtime_id"

cp "$publish_dir/dotfiles" "$output_binary"
chmod +x "$output_binary"

log_info "Running single executable verification: $output_binary check dotnet"
"$output_binary" check dotnet
