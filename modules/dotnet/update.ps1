. $env:DOTFILES_HOME/bin/functions.ps1

# Update dotnetup and the SDKs it tracks
$env:PATH = "$(Join-Path $HOME ".dotnetup");$env:PATH"
Log-Info "Updating dotnetup and .NET SDKs..."
dotnetup self update
dotnetup update --interactive false --no-progress

# Update .NET CLI tools
Log-Info "Updating .NET CLI tools..."
dotnet tool update -g dotnet-ef
dotnet tool update -g dotnet-user-secrets
dotnet tool update -g security-scan
dotnet tool update -g dotnet-dev-certs
