#!/usr/bin/env powershell

# Add dotfiles bin
$DOTFILES_HOME=$(Join-Path $env:USERPROFILE ".dotfiles")
$DOTFILES_BIN=$(Join-Path $DOTFILES_HOME "bin")
$LOCAL_BIN=$(Join-Path $env:USERPROFILE ".local\bin")
$env:PNPM_HOME=$LOCAL_BIN
$env:PATH="$DOTFILES_BIN;$LOCAL_BIN;C:\Program Files\Rust stable GNU 1.93\bin;$env:PATH"

$env:PROGRAMS=$(Join-Path "C:" "Programs")

Import-Module posh-git
Import-Module PSReadLine
Import-Module Terminal-Icons

oh-my-posh init pwsh --config "$DOTFILES_HOME/modules/oh-my-posh/.config/omp.json" | Invoke-Expression

mise activate pwsh | Out-String | Invoke-Expression

if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }

Set-Alias -Name docker -Value podman

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

function zsh {
    wsl ~ -e /bin/zsh
}
