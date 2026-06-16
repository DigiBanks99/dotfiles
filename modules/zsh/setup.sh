#!/usr/bin/env bash

set -euo pipefail

module_brew_bundle zsh

source "$DOTFILES_HOME/modules/zsh/$DOTFILES_PROFILE_NAME/setup.sh"