#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$DOTFILES_HOME/modules/git"

sed "s/EMAILADDRESS/$EMAIL_ADDRESS/g" "$MODULE_DIR/.config/.gitconfig.template" > "$MODULE_DIR/.config/.gitconfig"
ln -sf "$MODULE_DIR/.config/.gitconfig" "$HOME/.gitconfig"

module_brew_bundle git
