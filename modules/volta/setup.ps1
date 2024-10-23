. $env:DOTFILES_HOME/bin/functions.ps1

winget install -e --id "Volta.Volta" -h

# Setup Node
Log-Info "Setting up Node..."
volta install node@lts
volta install npm@bundled

npm install --global azurite@latest
npm install --global azure-functions-core-tools@latest
npm install --global rimraf@latest
npm install --global prettier@latest
