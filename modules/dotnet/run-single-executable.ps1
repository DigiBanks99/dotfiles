. $env:DOTFILES_HOME/bin/functions.ps1

function Resolve-RuntimeIdentifier {
    $architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture

    if ($IsWindows) {
        switch ($architecture) {
            "Arm64" { return "win-arm64" }
            "X64" { return "win-x64" }
        }
    } elseif ($IsMacOS) {
        switch ($architecture) {
            "Arm64" { return "osx-arm64" }
            "X64" { return "osx-x64" }
        }
    } elseif ($IsLinux) {
        switch ($architecture) {
            "Arm64" { return "linux-arm64" }
            "X64" { return "linux-x64" }
        }
    }

    throw "Unsupported runtime for single-file publish: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription) / $architecture"
}

$runtimeId = Resolve-RuntimeIdentifier
$publishDir = Join-Path $env:DOTFILES_HOME "bin/Release/net8.0/$runtimeId/publish"
$binaryName = if ($runtimeId.StartsWith("win-")) { "dotfiles.exe" } else { "dotfiles" }
$publishedBinary = Join-Path $publishDir $binaryName
$outputBinary = Join-Path $env:DOTFILES_BIN $binaryName

Log-Info "Publishing dotfiles single executable for runtime '$runtimeId'..."
dotnet publish "$env:DOTFILES_HOME/dotfiles.csproj" `
    -c Release `
    -r $runtimeId

Copy-Item -Path $publishedBinary -Destination $outputBinary -Force
if (-not $runtimeId.StartsWith("win-")) {
    chmod +x $outputBinary
}

Log-Info "Running single executable verification: $outputBinary check dotnet"
& $outputBinary check dotnet
