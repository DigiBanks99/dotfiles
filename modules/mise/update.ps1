. $DOTFILES_HOME/bin/bootstrap.ps1

winget update -e --id "jdx.mise" -h

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

$pnpmExecutable = Join-Path (Split-Path -Parent $npmExecutable) "pnpm.cmd"
if (-not (Test-Path $pnpmExecutable)) {
	throw "Unable to resolve 'pnpm.cmd' after configuring Node with mise."
}

$corepackExecutable = Join-Path (Split-Path -Parent $npmExecutable) "corepack.cmd"
if (-not (Test-Path $corepackExecutable)) {
	throw "Unable to resolve 'corepack.cmd' after configuring Node with mise."
}

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

& $npmExecutable install -g rimraf@latest prettier@latest