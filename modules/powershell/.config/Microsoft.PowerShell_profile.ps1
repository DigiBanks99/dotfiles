#!/usr/bin/env powershell

# Add dotfiles bin
$DOTFILES_HOME=$(Join-Path $env:USERPROFILE ".dotfiles")
$DOTFILES_BIN=$(Join-Path $DOTFILES_HOME "bin")
$env:PATH="$env:PATH;$DOTFILES_BIN"

Import-Module posh-git

oh-my-posh init pwsh  --config "$DOTFILES_HOME/modules/oh-my-posh/.config/omp.json" | Invoke-Expression

Import-Module Terminal-Icons
Import-Module PSReadLine
Import-Module powershell-yaml

Set-Alias -Name docker -Value podman

Set-Alias -Name zsh -Value "wsl -e /bin/zsh"

# Configure aliases
function poof {
    git add .; git amendne; git poof
}

function godot {
    pwsh -noprofile -command "Start-Process 'Godot v4.2.exe'"
}

function godotlts {
    pwsh -noprofile -command "Start-Process 'Godot v4.1.2.exe'"
}

function touch {
    New-Item -Name $args[0] -Type File
}
