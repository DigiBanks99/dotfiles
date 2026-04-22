#!/usr/bin/env zsh

set -euo pipefail

DIR="${0:A:h}"

sub_command="${1:-}"
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