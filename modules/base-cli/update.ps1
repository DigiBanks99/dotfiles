. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Installing bat"
winget update -e --id "sharkdp.bat" -h
Log-Info "Installing Windows Terminal"
winget update -e --id "Microsoft.WindowsTerminal" -h
Log-Info "Installing Azure CLI"
winget update -e --id "Microsoft.AzureCLI" -h
Log-Info "Installing OhMyPosh"
winget update -e --id "JanDeDobbeleer.OhMyPosh" -h

Log-Info "Configuring Windows Terminal"
$wtSettingsPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtSettingsTarget = Join-Path $env:DOTFILES_HOME "modules/base-cli/.config/settings.json"

$existingSettings = Get-Item -Path $wtSettingsPath -Force -ErrorAction SilentlyContinue
if ($existingSettings) {
	$existingTarget = @($existingSettings.Target) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
	if ($existingSettings.LinkType -eq "SymbolicLink" -and $existingTarget -contains $wtSettingsTarget) {
		Log-Info "Windows Terminal settings link already configured."
		return
	}

	Log-Info "Removing existing Windows Terminal settings..."
	Remove-Item -Path $wtSettingsPath -Force
}

Log-Info "Creating symbolic link for Windows Terminal settings..."
