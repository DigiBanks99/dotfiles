#!/usr/bin/env bash

. $DOTFILES_BIN/bootstrap.sh

log_debug "$DOTFILES_BIN/is-executable brew: $($DOTFILES_BIN/is-executable brew && echo "true" || echo "false")"
if [[ `$DOTFILES_BIN/is-executable brew` == "0" ]]; then
    brew update
    brew upgrade
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # temporarily setup the path to allow the setup to continue
    if [[ "$(uname -p)" == "arm" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    fi
fi