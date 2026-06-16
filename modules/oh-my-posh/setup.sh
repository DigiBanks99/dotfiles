#!/usr/bin/env zsh

set -euo pipefail

# Download Oh-My-Posh theme from gist
log_info "Downloading Oh My Posh theme from gist..."
gist_url="https://gist.githubusercontent.com/DigiBanks99/85047566c5c63ec7daa423df086e2535/raw/baddc4c520b9157c5141eb06b6aecbb06720701c/catppuccin-frappe.omp.json"
mkdir -p "$DOTFILES_HOME/modules/oh-my-posh/.config"
omp_theme_file="$DOTFILES_HOME/modules/oh-my-posh/.config/omp.json"
log_debug "Checking if theme is already downloaded at $omp_theme_file..."
if [[ -f "$omp_theme_file" ]]; then
    log_info "Oh My Posh theme already exists at $omp_theme_file, skipping download."
else
    if curl -fsSL "$gist_url" -o "$omp_theme_file"; then
        log_info "Successfully downloaded Oh My Posh theme to $omp_theme_file"
    else
        log_error "Failed to download Oh My Posh theme from $gist_url"
    fi
fi

# Install Oh My Posh via Homebrew
module_brew_bundle oh-my-posh
