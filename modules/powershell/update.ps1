. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Updating PowerShell"
winget update -e --id "Microsoft.PowerShell" -h

# Install powershell modules
Log-Info "Updating PowerShell modules (posh-git, Terminal-Icons, PSReadLine, powershell-yaml)..."
pwsh -Command "Remove-Module posh-git && Update-Module -Name posh-git -Scope CurrentUser -Force"
pwsh -Command "Remove-Module Terminal-Icons && Update-Module -Name Terminal-Icons -Scope CurrentUser -Force"
pwsh -Command "Remove-Module PSReadLine && Update-Module -Name PSReadLine -Scope CurrentUser -Force"
pwsh -Command "Remove-Module powershell-yaml && Update-Module -Name powershell-yaml -Scope CurrentUser -Force"
