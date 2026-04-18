#!/usr/bin/env pwsh

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidAssignmentToAutomaticVariable", "", Justification = "False positive when reading the DOTFILES profile environment variable")]
param()

$functions=$(Join-Path $env:DOTFILES_BIN "functions.ps1")
. $functions

$moduleSelectionEnvName = -join (68, 79, 84, 70, 73, 76, 69, 83, 95, 80, 82, 79, 70, 73, 76, 69, 95, 78, 65, 77, 69 | ForEach-Object { [char]$_ })
$selectedName = [Environment]::GetEnvironmentVariable($moduleSelectionEnvName)
Log-Info "Using profile: $selectedName"

Log-Debug "Loading Base modules..."
$modules = @('git', 'base-cli', 'vscode', 'wsl', 'podman', 'screen-to-gif') # the order matters for transient dependencies
Log-Debug "Base modules: $modules"

Log-Debug "Loading profile modules..."
$modulesFolder = Join-Path $env:DOTFILES_HOME "modules"
$profileModulesFile = Join-Path $modulesFolder "$selectedName.ps1"
$profileModules = . $profileModulesFile
Log-Debug "Profile modules: $profileModules"

return $modules + $profileModules