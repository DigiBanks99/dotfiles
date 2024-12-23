. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Installing bat"
winget install -e --id "sharkdp.bat" -h
Log-Info "Installing Windows Terminal"
winget install -e --id "Microsoft.WindowsTerminal" -h
Log-Info "Installing Azure CLI"
winget install -e --id "Microsoft.AzureCLI" -h
Log-Info "Installing OhMyPosh"
winget install -e --id "JanDeDobbeleer.OhMyPosh" -h
