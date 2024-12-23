. $env:DOTFILES_HOME/bin/bootstrap.ps1

Log-Info "Installing bat"
winget update -e --id "sharkdp.bat" -h
Log-Info "Installing Windows Terminal"
winget update -e --id "Microsoft.WindowsTerminal" -h
Log-Info "Installing Azure CLI"
winget update -e --id "Microsoft.AzureCLI" -h
Log-Info "Installing OhMyPosh"
winget update -e --id "JanDeDobbeleer.OhMyPosh" -h
