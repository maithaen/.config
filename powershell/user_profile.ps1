
# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# # theme
oh-my-posh init pwsh | Invoke-Expression
& ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin.omp.json" --print) -join "`n"))



# Env
# $env:GIT_SSH = "C:\Program Files\Git\usr\bin\OpenSSH\ssh.exe"
. $env:USERPROFILE\.config\powershell\user_profile.ps1
#########

# Alias
Remove-Alias -Name where -Force
Remove-Alias -Name ls -Force
Remove-Alias -Name man -Force
Set-Alias -Name less -Value "C:\Program Files\Git\usr\bin\less.exe"
Set-Alias -Name grep -Value "C:\Program Files\Git\usr\bin\grep.exe"
Set-Alias -Name find -Value "C:\Program Files\Git\usr\bin\find.exe"
Set-Alias -Name where -Value "C:\Windows\System32\where.exe"
Set-Alias -Name ssh -Value "C:\Windows\System32\OpenSSH\ssh.exe"
Set-Alias -Name rm -Value "C:\Program Files\Git\usr\bin\rm.exe"
Set-Alias -Name bash -Value "C:\Program Files\Git\bin\bash.exe"
Set-Alias -Name open -Value "C:\Windows\explorer.exe"
Set-Alias -Name ls -Value "eza"
Set-Alias -Name vim -Value "nvim"
Set-Alias -Name cat -Value "bat"
Set-Alias -Name py -Value "python"
Set-Alias -Name man -Value "tldr"
Set-alias -Name reboot -Value "Restart-Computer"
Set-alias -Name shutdown -Value "Stop-Computer"
Set-Alias -Name zsh -Value "wsl"
Set-Alias -Name arch -Value "wsl"
Set-Alias -Name co -Value "code"




# which
function which($command){
  $path = (Get-Command $command).Path
  if ($path){
    return $path
    } else {
      Write-Output "$command not found"
    }
}

# Lsd icons
function ll {
    return Get-Location && lsd -1 -lA --human-readable --group-directories-first --extensionsort --blocks permission --blocks size --blocks date --blocks name
}
 
# Tree
function tt {
	return eza --tree -L2 --icons
}
# Android
function sy {
    return scrcpy --turn-screen-off --max-fps=50 # --no-audio
}
function otg {
  Write-Output "Alt+Shift to toggle mouse nd keyboard in windows"
  return scrcpy.exe --otg -K -M -s e4ce11d11220 
}

function neofetch {
    return bash neofetch
 }

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
