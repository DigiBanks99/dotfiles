. $env:DOTFILES_HOME/bin/functions.ps1

Log-Info "Installing bat"
winget install -e --id "sharkdp.bat" -h
Log-Info "Installing Windows Terminla"
winget install -e --id "Microsoft.WindowsTerminal" -h
Log-Info "Installing Azure CLI"
winget install -e --id "Microsoft.AzureCLI" -h
