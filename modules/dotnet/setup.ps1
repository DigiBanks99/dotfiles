. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Install .NET SDK
winget install -e --id "Microsoft.DotNet.Sdk.8" -h
winget install -e --id "Microsoft.DotNet.Sdk.9" -h

# Install .NET CLI tools
Log-Info "Installing .NET CLI tools..."
dotnet tool install -g dotnet-ef
dotnet tool install -g dotnet-user-secrets
dotnet tool install -g security-scan
dotnet tool install -g dotnet-dev-certs

# Add .NET SDK and tools to the PATH
Log-Info "Adding .NET SDK and tools to the PATH..."
$DOTNET_PATH=$(Join-Path $env:USERPROFILE ".dotnet")
$DOTNET_TOOL_PATH=$(Join-Path $DOTNET_PATH "tools")
$env:PATH="$($env:PATH);$DOTNET_PATH;$DOTNET_TOOL_PATH"
