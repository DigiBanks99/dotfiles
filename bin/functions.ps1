function Get-LogLevel {
    switch ($env:DOTFILES_LOG_LEVEL) {
        "1" { return 1 }
        "ERROR" { return 1 }
        "2" { return 2 }
        "WARN" { return 2 }
        "3" { return 3 }
        "INFO" { return 3 }
        "4" { return 4 }
        "DEBUG" { return 4 }
        Default { return 3 }
    }
}

function Log-Error {
    param([string]$message)
    if ((Get-LogLevel) -ge 1) {
        Write-Host "[ERR]: $message" -ForegroundColor Red
    }
}

function Log-Warn {
    param([string]$message)
    if ((Get-LogLevel) -ge 2) {
        Write-Host "[WARN]: $message" -ForegroundColor Yellow
    }
}

function Log-Info {
    param([string]$message)
    if ((Get-LogLevel) -ge 3) {
        Write-Host "[INF]:" -ForegroundColor Cyan -NoNewLine
        Write-Host " $message"
    }
}

function Log-Debug {
    param([string]$message)
    if ((Get-LogLevel) -ge 4) {
        Write-Host "[DBG]:" -ForegroundColor Green -NoNewLine
        Write-Host " $message"
    }
}

function Check-Command {
    param([string]$command)
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Log-Error "Command not found: $command"
        return $false
    }
    return $true
}

function Get-Os {
    if ($IsWindows) {
        return "windows"
    } elseif ($IsMacOS) {
        return "Darwin"
    } else {
        return "Nix"
    }
}

function Execute-Elevated {
    $OS = Get-Os
    switch ($OS) {
        "windows" {
            if (Check-Command "sudo") {
                Log-Debug "Running command elevated: $args"
                sudo run --inline $args
            } else {
                $args | Invoke-Expression
            }
        }
        "Nix" {
            sudo $args
        }
    }
}