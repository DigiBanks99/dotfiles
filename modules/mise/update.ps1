. $DOTFILES_HOME/bin/bootstrap.ps1

winget update -e --id "jdx.mise" -h

# Setup Node
Log-Info "Setting up Node..."
mise use node@lts
npm install -g corepack@latest
corepack enable pnpm

pnpm install --global rimraf@latest
pnpm install --global prettier@latest