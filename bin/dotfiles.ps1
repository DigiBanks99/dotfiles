#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$DIR=$(Split-Path -Parent $MyInvocation.MyCommand.Definition)
. "$DIR/bootstrap.ps1"

$subCommand = $args[0]
switch ($subCommand) {
    "setup" {
        Execute-Elevated pwsh "$env:DOTFILES_BIN/dotfiles-setup.ps1"
        break
     }
    "update" {
        Execute-Elevated pwsh "$env:DOTFILES_BIN/dotfiles-update.ps1"
        break
     }
    Default {
        Log-Error "'$subCommand' is not supported. Run 'dotfiles help' to see available options."
        exit 1
    }
}
