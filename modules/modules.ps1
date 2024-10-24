#!/usr/bin/env pwsh

$functions=$(Join-Path $env:DOTFILES_BIN "functions.ps1")
. $functions

$PROFILE=$env:DOTFILES_PROFILE_NAME
Log-Info "Using profile: $PROFILE"

Log-Debug "Loading Base modules..."
$modules = @('git', 'base-cli', 'vscode', 'wsl', 'podman', 'screen-to-gif') # the order matters for transient dependencies
Log-Debug "Base modules: $modules"

Log-Debug "Loading profile modules..."
$modulesFolder = Join-Path $env:DOTFILES_HOME "modules"
$profileModulesFile = Join-Path $modulesFolder "$($PROFILE).ps1"
$profileModules = . $profileModulesFile
Log-Debug "Profile modules: $profileModules"

return $modules + $profileModules