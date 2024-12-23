. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Installing PowerShell"
winget install -e --id "Microsoft.PowerShell" -h

# Install powershell modules
Log-Info "Installing PowerShell modules (posh-git, Terminal-Icons, PSReadLine, powershell-yaml)"
pwsh -Command "Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name powershell-yaml -Scope CurrentUser -Force -AllowClobber"

Log-Info "Configuring PowerShell profile"
$profileInfo=$profile | select CurrentUserCurrentHost
$profilePath=$profile.CurrentUserCurrentHost
Remove-Item -Path "$profilePath" -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path "$profilePath" -Target $env:DOTFILES_HOME/modules/powershell/.config/Microsoft.PowerShell_profile.ps1

. $PROFILE