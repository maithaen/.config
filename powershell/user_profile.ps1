# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# theme

$omp_config = Join-Path $PSScriptRoot ".\agnoster.omp.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

# module
# Import-Module z
# Import-Module posh-git
Import-Module -Name Terminal-Icons

# PSReadLine
# Set-PSReadLineOption -EditMode Emacs
# Set-PSReadLineOption -BellStyle None
# Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
# Set-PSReadLineOption -PredictionSource History


Set-PSReadLineOption -PredictionViewStyle ListView




# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

# Alias
Remove-Alias -Name ls
Set-Alias -Name vim -Value nvim
Set-Alias -Name g -Value git
Set-Alias -Name grep -Value findstr
Set-Alias -Name less -Value 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias -Name ll -Value Get-ChildItem 
Set-Alias -Name rm -Value 'C:\Program Files\Git\usr\bin\rm.exe'
Set-Alias -Name lo -Value 'C:\Windows\System32\where.exe'
