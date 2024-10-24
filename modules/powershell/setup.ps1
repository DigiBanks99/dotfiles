. $env:DOTFILES_HOME/bin/functions.ps1

Log-Info "Installing PowerShell"
winget install -e --id "Microsoft.PowerShell" -h
Log-Info "Installing OhMyPosh"
winget install -e --id "JanDeDobbeleer.OhMyPosh" -h

# Install powershell modules
Log-Info "Installing PowerShell modules (posh-git, Terminal-Icons, PSReadLine, powershell-yaml)"
pwsh -Command "Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber"
pwsh -Command "Install-Module -Name powershell-yaml -Scope CurrentUser -Force -AllowClobber"

# Configure profile
Log-Info "Fetching OhMyPosh theme"
curl -Outfile $env:DOTFILES_HOME/modules/powershell/.config/digi.omp.json -Uri https://gist.githubusercontent.com/DigiBanks99/af8e4e0ecdcddd7105e47823f02be90e/raw/9db51d9caeb6db46eeffcb36636eb5e66ad5e0d8/digi.omp.json

Log-Info "Configuring PowerShell profile"
mkdir $env:USERPROFILE/.config/powershell -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE/.config/powershell/Microsoft.PowerShell_profile.ps1 -Target $env:DOTFILES_HOME/modules/powershell/.config/Microsoft.PowerShell_profile.ps1
