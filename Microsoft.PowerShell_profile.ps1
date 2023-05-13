# . $env:USERPROFILE\.config\Powershell\user_profile.ps1
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/takuya.omp.json" | Invoke-Expression

# module
# Import-Module z
# Import-Module posh-git
# Import-Module -Name Terminal-Icons

# PSReadLine
# Set-PSReadLineOption -EditMode Emacs
# Set-PSReadLineOption -BellStyle None
# Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
# Set-PSReadLineOption -PredictionSource History


# Set-PSReadLineOption -PredictionViewStyle ListView




# Env
$env:GIT_SSH = "C:\Program Files\Git\usr\bin\OpenSSH\ssh.exe"
#########
# Use scoop install lsd bat
#########

# Alias
Remove-Alias -Name ls 
# Set-Alias -Name ls -Value 'C:\Program Files\Git\usr\bin\ls.exe'
# Set-Alias -Name ls -Value 'lsd'
Set-Alias -Name less -Value 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias -Name rm -Value 'C:\Program Files\Git\usr\bin\rm.exe'
Set-Alias -Name bash -Value "C:\Program Files\Git\bin\bash.exe"
Set-Alias -Name lo -Value 'C:\Windows\System32\where.exe'
Set-Alias -Name whereis -Value 'C:\Windows\System32\where.exe'
Set-Alias -Name ls -Value "lsd"
Set-Alias -Name cat -Value "bat"


function ll {
    return pwd && lsd -1 -la --human-readable --group-directories-first --extensionsort --blocks permission --blocks size --blocks date --blocks name
}
