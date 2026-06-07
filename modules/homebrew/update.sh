#!/usr/bin/env bash

. $DOTFILES_BIN/bootstrap.sh

brew update
brew upgrade
brew upgrade --cask
brew cleanup
