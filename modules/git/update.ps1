. $env:DOTFILES_HOME/bin/bootstrap.ps1

winget update -e --id "Git.Git" -h

# Replace EMAILADDRESS placeholder in .gitconfig.template and write to .gitconfig
$moduleDir = "$env:DOTFILES_HOME\modules\git"
$templatePath = "$moduleDir\.config\.gitconfig.template"
$configPath = "$moduleDir\.config\.gitconfig"
(Get-Content $templatePath) -replace 'EMAILADDRESS', $env:EMAIL_ADDRESS | Set-Content $configPath

# Link the generated .gitconfig to the user's home directory
$homeConfigPath = "$env:HOME\.gitconfig"
if (Test-Path $homeConfigPath) {
    Remove-Item $homeConfigPath -Force
}
New-Item -ItemType SymbolicLink -Path $homeConfigPath -Target $configPath