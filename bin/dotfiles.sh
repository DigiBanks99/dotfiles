#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sub_command="${1:-}"
echo "Running 'dotfiles $sub_command'..."
case "$sub_command" in
    setup)
        bash "$DIR/dotfiles-setup.sh"
        ;;
    update)
        bash "$DIR/dotfiles-update.sh"
        ;;
    *)
        echo "[ERR]: '$sub_command' is not supported. Run 'dotfiles help' to see available options." >&2
        exit 1
        ;;
esac
