#!/usr/bin/env powershell

# Add dotfiles bin
$DOTFILES_HOME=$(Join-Path $env:USERPROFILE ".dotfiles")
$DOTFILES_BIN=$(Join-Path $DOTFILES_HOME "bin")
$env:PATH="$env:PATH;$DOTFILES_BIN"

Import-Module posh-git

oh-my-posh init pwsh "$DOTFILES_HOME/modules/powershell/.config/digi.omp.json" | Invoke-Expression

Import-Module Terminal-Icons
Import-Module PSReadLine
Import-Module powershell-yaml

# Start podman machine
$podmanMachineStatus = (podman machine info | Out-String | ConvertFrom-Yaml).host.machineState
if ($podmanMachineStatus -eq "Stopped" -and $env:PODMAN_STARTING -eq $false) {
    $env:PODMAN_STARTING = $true
    podman machine start -q
    $env:PODMAN_STARTING = $false
}

Set-Alias -Name docker -Value podman
