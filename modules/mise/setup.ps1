. $env:DOTFILES_HOME/bin/bootstrap.ps1

$miseAlreadyInstalled = $null -ne (Get-Command mise -ErrorAction SilentlyContinue)
if (-not $miseAlreadyInstalled) {
    Log-Info "Installing mise..."
    winget install -e --id "jdx.mise" -h
    # 0x8A150011 (-1978335189) means already installed — treat as success
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
        throw "Failed to install mise via winget (exit code: $LASTEXITCODE)"
    }
} else {
    Log-Info "mise is already installed, skipping."
}

# Refresh PATH for this session so newly installed commands are discoverable.
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathParts = @($machinePath, $userPath)

$miseBin = Join-Path $env:LOCALAPPDATA "mise\bin"
$miseShims = Join-Path $env:LOCALAPPDATA "mise\shims"
if (Test-Path $miseBin) {
	$pathParts += $miseBin
}
if (Test-Path $miseShims) {
	$pathParts += $miseShims
}

$env:Path = ($pathParts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ";"

$miseCommand = Get-Command mise -ErrorAction SilentlyContinue
if (-not $miseCommand) {
	throw "Unable to resolve 'mise' after installation."
}

# Setup Node
Log-Info "Setting up Node..."
mise use node@lts

$npmCommand = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCommand) {
	throw "Unable to resolve 'npm' after configuring Node with mise."
}

$npmExecutable = $npmCommand.Path
if ([string]::IsNullOrWhiteSpace($npmExecutable)) {
	throw "Unable to determine the executable path for 'npm'."
}

$corepackCommand = Get-Command corepack -ErrorAction SilentlyContinue
if (-not $corepackCommand) {
	throw "Unable to resolve 'corepack' after configuring Node with mise."
}
$corepackExecutable = $corepackCommand.Path

$pnpmHome = Join-Path $env:USERPROFILE ".local\bin"
if (-not (Test-Path $pnpmHome)) {
	New-Item -ItemType Directory -Path $pnpmHome -Force | Out-Null
}

$env:PNPM_HOME = $pnpmHome
if (($env:Path -split ";") -notcontains $pnpmHome) {
	$env:Path = "$pnpmHome;$env:Path"
}

[Environment]::SetEnvironmentVariable("PNPM_HOME", $pnpmHome, "User")

& $npmExecutable install -g corepack@latest
& $corepackExecutable enable pnpm

# Regenerate mise shims so pnpm becomes discoverable in PATH
mise reshim

$pnpmCommand = Get-Command pnpm -ErrorAction SilentlyContinue
if (-not $pnpmCommand) {
	throw "Unable to resolve 'pnpm' after enabling with corepack."
}

& $npmExecutable install -g rimraf@latest prettier@latest
