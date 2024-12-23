#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$DIR=$(Split-Path -Parent $MyInvocation.MyCommand.Definition)
. "$DIR/bootstrap.ps1"

function Verify-PackageManger {
    Log-Info "Verifying package manager..."
    if ($OS -eq "windows") {
        if (-not (Check-Command "winget")) {
            Log-Error "Winget was not found on your Windows machine. This could mean that you are not running Windows 10 or later, or need to update your system."
            exit 1
        }

        return "winget"
    } elseif ($OS -eq "Darwin") {
        if (-not (Check-Command "brew")) {
            Log-Error "Homebrew is not installed. Please ensure you have Homebrew installed."
            exit 1
        }

        return "brew"
    } else {
        $packageManagers = @("apt", "yum", "dnf", "zypper", "pacman", "emerge", "winget")
        $packageManager = Read-Host "What package manager do you use ($packageManagers)? "
        if (-not (Check-Command $packageManager)) {
            Log-Error "Package manager not found: $packageManager"
            exit 1
        }
        return $packageManager
    }
}

# Verify package manager is installed
$packageManager=$(Verify-PackageManger)
Log-Debug "Package manager: $packageManager"

# Set profile if not set
Log-Debug "Profile: $env:DOTFILES_PROFILE_NAME"
if ($env:DOTFILES_PROFILE_NAME -eq $null) {
    Log-Debug "Profile not set. Prompting user..."
    $profile=$(Read-Host -Prompt "What profile are you configuring?")
    Log-Debug "Profile: $profile"
    $env:DOTFILES_PROFILE_NAME=$profile
}

# Load profile modules
Log-Info "Reading profile modules..."
$modulesFolder=$(Join-Path $env:DOTFILES_HOME "modules")
$modulesFile=$(Join-Path $modulesFolder "modules.ps1")
Log-Debug "Modules file: $modulesFile"
$modules=@($(. $modulesFile))
Log-Debug "Modules: $modules"

foreach ($module in $modules) {
    $modulePath=$(Join-Path $modulesFolder $module)
    $moduleFile=$(Join-Path $modulePath "setup.ps1")
    Log-Info "Installing module: $module..."
    . $moduleFile
}
