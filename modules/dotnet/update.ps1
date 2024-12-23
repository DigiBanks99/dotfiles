. $env:DOTFILES_HOME/bin/functions.ps1

# Update .NET SDK
winget update -e --id "Microsoft.DotNet.Sdk.8" -h
winget update -e --id "Microsoft.DotNet.Sdk.9" -h

# Update .NET CLI tools
Log-Info "Installing .NET CLI tools..."
dotnet tool update -g dotnet-ef
dotnet tool update -g dotnet-user-secrets
dotnet tool update -g security-scan
dotnet tool update -g dotnet-dev-certs
