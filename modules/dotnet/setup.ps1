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
dotnetup sdk install latest 8.0 10.0 11.0 --interactive false --no-progress

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

# Native AOT needs the MSVC linker and a Windows SDK
Log-Info "Ensuring C++ build tools for Native AOT..."
$vcComponent = "Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
$vsInstallerDir = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio/Installer"
$vswhere = Join-Path $vsInstallerDir "vswhere.exe"

$hasVcTools = (Test-Path $vswhere) -and
    -not [string]::IsNullOrWhiteSpace((& $vswhere -products * -requires $vcComponent -property installationPath))

if ($hasVcTools) {
    Log-Info "C++ build tools already installed."
} else {
    $vsInstallPath = if (Test-Path $vswhere) {
        & $vswhere -products * -latest -property installationPath
    }
    $vcArgs = "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive --norestart"

    if (-not [string]::IsNullOrWhiteSpace($vsInstallPath)) {
        # The installer's setup.exe rejects --wait (only the vs_*.exe bootstrappers accept it);
        # Start-Process -Wait blocks until it finishes instead.
        Log-Info "Adding C++ build tools workload to '$vsInstallPath' (UAC prompt)..."
        $vsSetup = Start-Process -FilePath (Join-Path $vsInstallerDir "setup.exe") `
            -ArgumentList "modify --installPath `"$vsInstallPath`" $vcArgs" `
            -Verb RunAs -Wait -PassThru
        # 3010 = success, reboot required
        if ($vsSetup.ExitCode -notin 0, 3010) {
            Log-Error "Visual Studio Installer failed (exit code $($vsSetup.ExitCode)); Native AOT publish will not work."
        }
    } else {
        Log-Info "Installing Visual Studio Build Tools with C++ workload..."
        winget install -e --id "Microsoft.VisualStudio.2022.BuildTools" -h --override "$vcArgs --wait"
    }
}

. "$env:DOTFILES_HOME/modules/dotnet/run-single-executable.ps1"
