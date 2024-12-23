. $env:DOTFILES_HOME/bin/bootstrap.ps1

winget update -e --id "Volta.Volta" -h

# Setup Node
Log-Info "Setting up Node..."
volta install node@lts
volta install npm@bundled

npm install --global azurite@latest
npm install --global azure-functions-core-tools@latest
npm install --global rimraf@latest
npm install --global prettier@latest

# Add volta completions
volta completions powershell -o $DIR_DOTFILES_HOME/volta/completions.ps1 -f
