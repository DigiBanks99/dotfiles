. $env:DOTFILES_HOME/bin/bootstrap.ps1

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

# Symlink ~/.claude/skills to the versioned skills directory
Log-Info "Linking ~/.claude/skills..."
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$claudeSkills = Join-Path $claudeDir "skills"
$skillsTarget = if ($moduleConfig) { [System.IO.Path]::GetFullPath((Join-Path $moduleConfig ".agents/skills")) } else { $null }
$skillsTargetReady = $skillsTarget -and (Test-Path -LiteralPath $skillsTarget -PathType Container)
if (-not $skillsTargetReady) { Log-Warn "Skills directory not found ($skillsTarget) — is DOTFILES_HOME set? Skipping ~/.claude/skills link." }
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
$existingSkills = Get-Item -Path $claudeSkills -ErrorAction SilentlyContinue -Force
$skillsBackup = $null
if ($skillsTargetReady -and $existingSkills -and $existingSkills.LinkType -ne 'SymbolicLink') {
    # A real directory: move it aside rather than delete it, then carry over app-managed state
    $skillsBackup = "$claudeSkills.bak-$(Get-Date -Format yyyyMMddHHmmss)"
    try {
        Move-Item -Path $claudeSkills -Destination $skillsBackup -ErrorAction Stop
    } catch {
        Log-Warn "Cannot move $claudeSkills aside — it may be in use. Close Claude and re-run setup."
        $skillsBackup = $null
    }
    if ($skillsBackup) {
        foreach ($keep in @("synced", ".trash")) {
            $source = Join-Path $skillsBackup $keep
            if (Test-Path $source) {
                Move-Item -Path $source -Destination (Join-Path $skillsTarget $keep)
            }
        }
        Log-Info "Previous ~/.claude/skills kept at $skillsBackup"
    }
}
if ($skillsTargetReady -and (-not (Test-Path $claudeSkills) -or $skillsBackup -or $existingSkills.LinkType -eq 'SymbolicLink')) {
    Set-DirSymlink -LinkPath $claudeSkills -Target $skillsTarget
}

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

