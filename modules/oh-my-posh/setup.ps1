. $env:DOTFILES_HOME/bin/bootstrap.ps1

# Install OhMyPosh
winget install -e --id "JanDeDobbeleer.OhMyPosh" -h

# Download and install my theme
$themePath="$env:DOTFILES_HOME/modules/oh-my-posh/.config/omp.json"
$theme=Test-Path -Path $themePath
if (-not $theme) {
    Log-Info "Fetching OhMyPosh theme"
    $themeUri="https://gist.githubusercontent.com/DigiBanks99/85047566c5c63ec7daa423df086e2535/raw/969a86885d590a439eb6c1ddb324c16849439536/catppuccin-frappe.omp.json"
    Invoke-WebRequest -Uri $themeUri -OutFile $themePath -UseBasicParsing -ErrorAction Stop
}