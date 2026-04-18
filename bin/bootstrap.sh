#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_HOME="$(dirname "$DIR")"
export DOTFILES_BIN="$DOTFILES_HOME/bin"

source "$DOTFILES_BIN/functions.sh"

OS="$(get_os)"
log_debug "OS: $OS"
