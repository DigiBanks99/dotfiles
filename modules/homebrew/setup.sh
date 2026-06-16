#!/usr/bin/env bash

. $DOTFILES_BIN/_bootstrap.zsh

#bash check if is-executable exits with 0
if $DOTFILES_BIN/is-executable brew; then
    log_info "Updating Homebrew..."
    brew update
    brew upgrade
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # temporarily setup the path to allow the setup to continue
    if [[ "$(uname -p)" == "arm" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"

        # include bash as initial shell setup
        echo 'eval "$(/home/homebrew/bin/brew shellenv bash)"' >> ~/.bashrc
        eval "$(/home/homebrew/bin/brew shellenv bash)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

        # include bash as initial shell setup
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> ~/.bashrc
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    fi
fi