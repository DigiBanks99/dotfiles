. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Update GitHub Copilot CLI
Log-Info "Updating GitHub Copilot CLI..."
winget update -e --id "GitHub.Copilot" -h

Log-Info "Refreshing agents module..."
. $env:DOTFILES_HOME/modules/agents/setup.ps1
