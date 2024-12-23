#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

# Set DOTFILES_HOME
$DIR=$(Split-Path -Parent $MyInvocation.MyCommand.Definition)
$env:DOTFILES_HOME="$(Split-Path $DIR -Parent)"
$env:DOTFILES_BIN=$(Join-Path $env:DOTFILES_HOME "bin")

# Configure terminal colors
$env:DOTFILES_NOCOLOUR="\033[0m"
$env:DOTFILES_RED="\033[0;31m"
$env:DOTFILES_GREEN="\033[0;32m"
$env:DOTFILES_YELLOW="\033[0;33m"
$env:DOTFILES_BLUE="\033[0;34m"
$env:DOTFILES_PURPLE="\033[0;35m"
$env:DOTFILES_CYAN="\033[0;36m"
$env:DOTFILES_WHITE="\033[0;37m"

# Load functions
$functions=$(Join-Path "$env:DOTFILES_BIN" "functions.ps1")
. $functions
Log-Debug "DOTFILES_HOME: $env:DOTFILES_HOME"

# Retrieve OS info
$OS = Get-Os
Log-Debug "OS: $OS"