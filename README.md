# dotfiles

Personal environment bootstrap for DigiBanks99 across Windows, macOS, and Linux.

## What this repository does

- Provides a `dotfiles` CLI entrypoint implemented in .NET.
- Runs setup/update workflows through shell and PowerShell scripts.
- Installs base developer modules (git, base-cli, vscode, podman, etc.) plus profile modules (for example `dotnet`, `oh-my-posh`, `mise`, `agents`).
- Configures tools and user profile files from the `modules/` folder.

## Supported operating systems

- Windows (PowerShell + winget)
- macOS (Bash/Zsh + Homebrew)
- Linux (Bash + distro package manager; currently ubuntu/fedora/nix profile prompts)

## Getting started

Clone this repository into your home directory as `.dotfiles`.

### Windows

1. Open PowerShell.
2. Run setup:
   ```powershell
   pwsh -File "$HOME\.dotfiles\bin\dotfiles.ps1" setup
   ```

### macOS

1. Open Terminal.
2. Run setup:
   ```bash
   bash "$HOME/.dotfiles/bin/dotfiles.sh" setup
   ```

### Linux

1. Open your terminal.
2. Run setup:
   ```bash
   bash "$HOME/.dotfiles/bin/dotfiles.sh" setup
   ```

## Running and updating

- Run setup again:
  - `dotfiles setup`
- Update installed modules:
  - `dotfiles update`

You can also call scripts directly:

- Bash/Zsh: `~/.dotfiles/bin/dotfiles.sh setup|update`
- PowerShell: `~/.dotfiles/bin/dotfiles.ps1 setup|update`

## .NET single executable

The project uses Native AOT (`PublishAot=true`), so dotnet module setup publishes a single executable and runs it at the end of setup to verify output.

- Linux/macOS output location: `~/.dotfiles/bin/dotfiles`
- Windows output location: `~/.dotfiles/bin/dotfiles.exe`

Verification command used by setup:

```bash
dotfiles check dotnet
```

You can also publish manually:

- Linux x64: `dotnet publish -c Release -r linux-x64`
- macOS arm64: `dotnet publish -c Release -r osx-arm64`
- Windows x64: `dotnet publish -c Release -r win-x64`

## Logging and debugging

Logging is controlled by `DOTFILES_LOG_LEVEL`:

- `ERROR` or `1`
- `WARN` or `2`
- `INFO` or `3` (default)
- `DEBUG` or `4`

Examples:

```bash
DOTFILES_LOG_LEVEL=DEBUG bash "$HOME/.dotfiles/bin/dotfiles.sh" setup
```

```powershell
$env:DOTFILES_LOG_LEVEL = "DEBUG"
pwsh -File "$HOME\.dotfiles\bin\dotfiles.ps1" setup
```

Log prefixes:

- `[ERR]` error
- `[WARN]` warning
- `[INF]` informational
- `[DBG]` debug
