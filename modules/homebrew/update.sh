#!/usr/bin/env bash

. $DOTFILES_BIN/_bootstrap.zsh

brew update
brew upgrade
brew upgrade --cask
brew cleanup
