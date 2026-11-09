. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Install Claude
Log-Info "Installing Claude..."
winget install -e --id "Anthropic.Claude" -h

# Install GitHub Copilot CLI
Log-Info "Installing GitHub Copilot CLI..."
winget install -e --id "GitHub.Copilot" -h

# Install agentsview CLI
if (-not (Get-Command agentsview -ErrorAction SilentlyContinue)) {
    Log-Info "Installing agentsview CLI..."
    powershell -ExecutionPolicy ByPass -c "irm https://agentsview.io/install.ps1 | iex"
} else {
    Log-Info "agentsview CLI already installed."
}

# Install agentsview desktop app (no winget package; use the release MSI)
$uninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$agentsViewApp = Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "AgentsView*" }
if (-not $agentsViewApp) {
    Log-Info "Installing agentsview desktop app..."
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    $release = Invoke-RestMethod "https://api.github.com/repos/kenn-io/agentsview/releases/latest"
    $asset = $release.assets | Where-Object { $_.name -like "AgentsView-*-windows-$arch.msi" } | Select-Object -First 1
    if ($asset) {
        $msi = Join-Path ([System.IO.Path]::GetTempPath()) $asset.name
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $msi
        Start-Process msiexec.exe -ArgumentList "/i", "`"$msi`"", "/qn" -Wait
        Remove-Item $msi -Force
    } else {
        Log-Warn "No agentsview Windows MSI found in the latest release. Install it manually from GitHub Releases."
    }
} else {
    Log-Info "agentsview desktop app already installed."
}

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

