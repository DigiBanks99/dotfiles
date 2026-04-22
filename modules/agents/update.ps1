. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Update Ollama
Log-Info "Updating Ollama..."
winget upgrade -e --id "Ollama.Ollama" -h

# Update Claude
Log-Info "Updating Claude..."
winget upgrade -e --id "Anthropic.Claude" -h

# Update GitHub Copilot CLI
Log-Info "Updating GitHub Copilot CLI..."
winget update -e --id "GitHub.Copilot" -h

Log-Info "Refreshing agents module..."
. $env:DOTFILES_HOME/modules/agents/setup.ps1
