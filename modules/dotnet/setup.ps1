. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Install dotnetup (user-level .NET toolchain manager)
$dotnetupHome = Join-Path $HOME ".dotnetup"
if (-not (Test-Path (Join-Path $dotnetupHome "dotnetup.exe"))) {
    Log-Info "Installing dotnetup..."
    Invoke-RestMethod https://aka.ms/dotnetup/get-dotnetup.ps1 | Invoke-Expression
} else {
    Log-Info "dotnetup is already installed, skipping."
}
$env:PATH = "$dotnetupHome;$env:PATH"

# Install .NET SDKs
Log-Info "Installing .NET SDKs with dotnetup..."
dotnetup install 8.0 10.0 --interactive false --no-progress

# Don't let dotnetup edit shell profiles; the managed profiles activate it via `dotnetup env script`.
dotnetup env set none --dotnetup-on-path true
dotnetup env script --shell pwsh --dotnet --dotnetup | Out-String | Invoke-Expression

# Install .NET CLI tools
Log-Info "Installing .NET CLI tools..."
dotnet tool install -g dotnet-ef
dotnet tool install -g dotnet-user-secrets
dotnet tool install -g security-scan
dotnet tool install -g dotnet-dev-certs

# Add .NET tools to the PATH
$DOTNET_TOOL_PATH = Join-Path $env:USERPROFILE ".dotnet/tools"
$env:PATH = "$($env:PATH);$DOTNET_TOOL_PATH"

. "$env:DOTFILES_HOME/modules/dotnet/run-single-executable.ps1"
