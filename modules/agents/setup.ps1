. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Install Ollama
Log-Info "Installing Ollama..."
winget install -e --id "Ollama.Ollama" -h

# Install Claude
Log-Info "Installing Claude..."
winget install -e --id "Anthropic.Claude" -h

# Install GitHub Copilot CLI
Log-Info "Installing GitHub Copilot CLI..."
winget install -e --id "GitHub.Copilot" -h

$moduleConfig = Join-Path $env:DOTFILES_HOME "modules/agents/.config"

function Set-DirSymlink {
    param(
        [string]$LinkPath,
        [string]$Target
    )
    $item = Get-Item -Path $LinkPath -ErrorAction SilentlyContinue -Force
    if ($item) {
        if ($item.LinkType -eq 'SymbolicLink') {
            if ($item.Target -eq $Target) {
                Log-Info "Symlink already correct: $LinkPath -> $Target"
                return
            }
            Remove-Item -Path $LinkPath -Force
        } else {
            try {
                Remove-Item -Path $LinkPath -Recurse -Force -ErrorAction Stop
            } catch {
                Log-Warn "Cannot remove $LinkPath — it may be in use. Rename it to *.bak and re-run setup."
                Log-Warn "  Rename-Item '$LinkPath' '$($LinkPath).bak'"
                return
            }
        }
    }
    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $Target | Out-Null
    Log-Info "Linked: $LinkPath -> $Target"
}

# Symlink .agents
Log-Info "Linking ~/.agents..."
Set-DirSymlink -LinkPath (Join-Path $env:USERPROFILE ".agents") -Target (Join-Path $moduleConfig ".agents")

# Symlink .copilot
Log-Info "Linking ~/.copilot..."
Set-DirSymlink -LinkPath (Join-Path $env:USERPROFILE ".copilot") -Target (Join-Path $moduleConfig ".copilot")

# Generate config.json from template
$configPath = Join-Path $moduleConfig ".copilot/config.json"
if (Test-Path (Join-Path $env:USERPROFILE ".copilot")) {
    Log-Info "Generating ~/.copilot/config.json from template..."
    $templatePath = Join-Path $moduleConfig "config.template.json"
    $userProfileEscaped = $env:USERPROFILE.Replace('\', '/')
    $config = (Get-Content $templatePath -Raw) -replace '\{\{USERPROFILE\}\}', $userProfileEscaped
    Set-Content -Path $configPath -Value $config -Encoding UTF8
    Log-Info "Done."
}

