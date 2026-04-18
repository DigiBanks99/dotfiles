. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Installing PowerShell"
winget install -e --id "Microsoft.PowerShell" -h

# Install powershell modules
Log-Info "Installing PowerShell modules (posh-git, Terminal-Icons, PSReadLine, powershell-yaml)"
pwsh -Command "Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber"

Log-Info "Configuring PowerShell profile"
$profilePath = $null
if ($PROFILE -is [string] -and -not [string]::IsNullOrWhiteSpace($PROFILE)) {
	$profilePath = $PROFILE
} elseif ($PROFILE -and $PROFILE.PSObject.Properties.Name -contains "CurrentUserCurrentHost") {
	$profilePath = $PROFILE.CurrentUserCurrentHost
}

if ([string]::IsNullOrWhiteSpace($profilePath)) {
	$documentsPath = [Environment]::GetFolderPath("MyDocuments")
	$profilePath = Join-Path $documentsPath "PowerShell/Microsoft.PowerShell_profile.ps1"
}

$profileDirectory = Split-Path -Parent $profilePath
$profileTarget = Join-Path $env:DOTFILES_HOME "modules/powershell/.config/Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $profileDirectory)) {
	Log-Info "Creating PowerShell profile directory..."
	New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
}

Log-Debug "The profile path is: $profilePath"

$existingProfile = Get-Item -Path $profilePath -Force -ErrorAction SilentlyContinue
if ($existingProfile) {
	$existingTarget = @($existingProfile.Target) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
	if ($existingProfile.LinkType -eq "SymbolicLink" -and $existingTarget -contains $profileTarget) {
		Log-Info "PowerShell profile link already configured."
		return
	}

	Log-Info "Removing existing PowerShell profile..."
	Remove-Item -Path $profilePath -Force
}

Log-Info "Creating symbolic link for profile..."
New-Item -ItemType SymbolicLink -Path $profilePath -Target $profileTarget | Out-Null
