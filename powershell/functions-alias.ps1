<#
.SYNOPSIS
    PowerShell utility functions and aliases for enhanced productivity.

.DESCRIPTION
    Provides enhanced directory listing, file operations, system utilities,
    and development tools with improved error handling and user experience.

.NOTES
    Version: 2.0
    Requires: PowerShell 5.1+
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ============================================
# Helper Functions
# ============================================

function Write-StatusMessage {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )
    
    $colors = @{
        Info    = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error   = "Red"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Type]
}

function Test-CommandExists {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# ============================================
# Command Discovery
# ============================================

function Find-CommandPath {
    <#
    .SYNOPSIS
        Locates the full path of a command.
    
    .DESCRIPTION
        Similar to Unix 'which' command. Finds and displays the full path
        of an executable or cmdlet.
    
    .PARAMETER Command
        The command name to locate.
    
    .EXAMPLE
        Find-CommandPath python
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Command
    )
    
    try {
        $cmd = Get-Command $Command -ErrorAction Stop
        
        if ($cmd.Path) {
            Write-Host $cmd.Path -ForegroundColor Green
            return $null
        } else {
            Write-StatusMessage "Command '$Command' found but has no path (built-in cmdlet)" "Warning"
            return $cmd.Name
        }
    }
    catch {
        Write-StatusMessage "Command '$Command' not found" "Error"
        return $null
    }
}

# ============================================
# Enhanced Directory Listing
# ============================================

function Get-DirectoryListDetailed {
    <#
    .SYNOPSIS
        Enhanced directory listing with detailed information.
    
    .DESCRIPTION
        Uses 'lsd' for beautiful directory listings with colors and icons.
        Falls back to Get-ChildItem if lsd is not available.
    
    .PARAMETER Path
        Path to list. Defaults to current directory.
    
    .EXAMPLE
        Get-DirectoryListDetailed
        Get-DirectoryListDetailed C:\Projects
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        Write-Host "$(Get-Location)" -ForegroundColor Cyan
        
        if (Test-CommandExists "lsd") {
            $lsdArgs = @(
                '-1',
                '-lA',
                '--human-readable',
                '--group-directories-first',
                '--extensionsort',
                '--blocks', 'permission',
                '--blocks', 'size',
                '--blocks', 'date',
                '--blocks', 'name'
            )
            
            if ($Arguments) {
                $lsdArgs += $Arguments
            }
            
            & lsd @lsdArgs
        }
        else {
            Write-StatusMessage "'lsd' not found. Using Get-ChildItem instead." "Warning"
            Get-ChildItem @Arguments
        }
    }
    catch {
        Write-StatusMessage "Error listing directory: $($_.Exception.Message)" "Error"
    }
}

function Get-DirectoryTree {
    <#
    .SYNOPSIS
        Displays directory structure as a tree.
    
    .DESCRIPTION
        Uses 'eza' to display a tree view of directories and files.
        Automatically filters common development artifacts.
    
    .PARAMETER Level
        Maximum depth of tree traversal (default: 3).
    
    .EXAMPLE
        Get-DirectoryTree
        Get-DirectoryTree -Level 5
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        if (-not (Test-CommandExists "eza")) {
            Write-StatusMessage "'eza' not found. Please install it first." "Error"
            return
        }
        
        $ezaArgs = @(
            '--tree',
            '-L3',
            '--icons',
            '--classify',
            '--group-directories-first',
            '--ignore-glob', '.git|.venv|node_modules|__pycache__|*.pyc|dist|build|*.egg-info'
        )
        
        if ($Arguments) {
            # Check if user provided custom level
            $hasLevelArg = $Arguments | Where-Object { $_ -match '^-L\d+$' }
            if ($hasLevelArg) {
                $ezaArgs = $ezaArgs | Where-Object { $_ -ne '-L3' }
            }
            $ezaArgs += $Arguments
        }
        
        & eza @ezaArgs
    }
    catch {
        Write-StatusMessage "Error generating tree view: $($_.Exception.Message)" "Error"
    }
}

# ============================================
# System Information
# ============================================

function Show-SystemInfo {
    <#
    .SYNOPSIS
        Displays system information using neofetch.
    
    .DESCRIPTION
        Runs neofetch through bash to display system information.
    
    .EXAMPLE
        Show-SystemInfo
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        if (-not (Test-CommandExists "bash")) {
            Write-StatusMessage "bash not found. Please install WSL or Git Bash." "Error"
            return
        }
        
        if ($Arguments) {
            & bash neofetch @Arguments
        } else {
            & bash neofetch
        }
    }
    catch {
        Write-StatusMessage "Error running neofetch: $($_.Exception.Message)" "Error"
    }
}

# ============================================
# Android/Mobile Tools
# ============================================

function Start-ScreenMirror {
    <#
    .SYNOPSIS
        Starts scrcpy for Android screen mirroring.
    
    .DESCRIPTION
        Launches scrcpy with optimized settings for screen mirroring.
    
    .PARAMETER MaxFps
        Maximum frames per second (default: 60).
    
    .EXAMPLE
        Start-ScreenMirror
        Start-ScreenMirror -MaxFps 30
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        if (-not (Test-CommandExists "scrcpy")) {
            Write-StatusMessage "scrcpy not found. Please install it first." "Error"
            return
        }
        
        $scrcpyArgs = @('--turn-screen-off', '--max-fps=60')
        
        if ($Arguments) {
            $scrcpyArgs += $Arguments
        }
        
        & scrcpy @scrcpyArgs
    }
    catch {
        Write-StatusMessage "Error running scrcpy: $($_.Exception.Message)" "Error"
    }
}

function Start-OTGMode {
    <#
    .SYNOPSIS
        Starts scrcpy in OTG mode for keyboard/mouse control.
    
    .DESCRIPTION
        Launches scrcpy in OTG mode with specific device serial.
        Use Alt+Shift to toggle between host and device control.
    
    .PARAMETER DeviceSerial
        Android device serial number.
    
    .EXAMPLE
        Start-OTGMode
        Start-OTGMode -DeviceSerial "abc123"
    #>
    [CmdletBinding()]
    param(
        [string]$DeviceSerial = "e4ce11d11220",
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        if (-not (Test-CommandExists "scrcpy")) {
            Write-StatusMessage "scrcpy not found. Please install it first." "Error"
            return
        }
        
        Write-StatusMessage "Alt+Shift to toggle mouse and keyboard control" "Info"
        
        $otgArgs = @('--otg', '-K', '-M', '-s', $DeviceSerial)
        
        if ($Arguments) {
            $otgArgs += $Arguments
        }
        
        & scrcpy @otgArgs
    }
    catch {
        Write-StatusMessage "Error running scrcpy OTG mode: $($_.Exception.Message)" "Error"
    }
}

# ============================================
# Profile Management
# ============================================

function Open-PowerShellProfile {
    <#
    .SYNOPSIS
        Opens PowerShell profile in Neovim.
    
    .DESCRIPTION
        Opens the current user's PowerShell profile for editing.
    
    .EXAMPLE
        Open-PowerShellProfile
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        if (-not (Test-Path $PROFILE)) {
            Write-StatusMessage "Profile not found. Creating new profile..." "Warning"
            New-Item -Path $PROFILE -ItemType File -Force | Out-Null
        }
        
        if ($Arguments) {
            & nvim $PROFILE @Arguments
        } else {
            & nvim $PROFILE
        }
    }
    catch {
        Write-StatusMessage "Error opening profile: $($_.Exception.Message)" "Error"
    }
}

function Open-PowerShellHistory {
    <#
    .SYNOPSIS
        Opens PowerShell command history in Neovim.
    
    .DESCRIPTION
        Opens the PSReadLine history file for viewing/editing.
    
    .EXAMPLE
        Open-PowerShellHistory
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        $historyPath = (Get-PSReadlineOption).HistorySavePath
        
        if (-not (Test-Path $historyPath)) {
            Write-StatusMessage "History file not found at: $historyPath" "Warning"
            return
        }
        
        if ($Arguments) {
            & nvim $historyPath @Arguments
        } else {
            & nvim $historyPath
        }
    }
    catch {
        Write-StatusMessage "Error opening PowerShell history: $($_.Exception.Message)" "Error"
    }
}

function Clear-PowerShellHistory {
    <#
    .SYNOPSIS
        Clears all PowerShell command history.
    
    .DESCRIPTION
        Removes both in-memory and file-based PowerShell command history.
    
    .PARAMETER Force
        Skip confirmation prompt.
    
    .EXAMPLE
        Clear-PowerShellHistory
        Clear-PowerShellHistory -Force
    #>
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    
    try {
        if (-not $Force) {
            $confirmation = Read-Host "Clear all PowerShell history? This cannot be undone. (y/n)"
            if ($confirmation -ne 'y') {
                Write-StatusMessage "Operation cancelled" "Warning"
                return
            }
        }
        
        # Clear in-memory history
        Clear-History
        
        # Clear history file
        $historyPath = (Get-PSReadlineOption).HistorySavePath
        if (Test-Path $historyPath) {
            Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
            New-Item -Path $historyPath -ItemType File -Force | Out-Null
        }
        
        Write-StatusMessage "PowerShell history cleared successfully" "Success"
    }
    catch {
        Write-StatusMessage "Error clearing PowerShell history: $($_.Exception.Message)" "Error"
    }
}

function Open-AllUsersProfile {
    <#
    .SYNOPSIS
        Opens the all users PowerShell profile.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        $profilePath = $PROFILE.AllUsersAllHosts
        
        if (-not (Test-Path $profilePath)) {
            Write-StatusMessage "Creating all users profile..." "Warning"
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }
        
        if ($Arguments) {
            & nvim $profilePath @Arguments
        } else {
            & nvim $profilePath
        }
    }
    catch {
        Write-StatusMessage "Error opening all users profile: $($_.Exception.Message)" "Error"
    }
}

function Open-CurrentUserProfile {
    <#
    .SYNOPSIS
        Opens the current user PowerShell profile.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        $profilePath = $PROFILE.CurrentUserAllHosts
        
        if (-not (Test-Path $profilePath)) {
            Write-StatusMessage "Creating current user profile..." "Warning"
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }
        
        if ($Arguments) {
            & nvim $profilePath @Arguments
        } else {
            & nvim $profilePath
        }
    }
    catch {
        Write-StatusMessage "Error opening current user profile: $($_.Exception.Message)" "Error"
    }
}


# ============================================
# Application Launchers
# ============================================

function Start-ComfyUI {
    <#
    .SYNOPSIS
        Launches ComfyUI application.
    
    .DESCRIPTION
        Starts ComfyUI with the configured Python virtual environment.
    
    .PARAMETER ComfyUIPath
        Path to ComfyUI installation.
    
    .EXAMPLE
        Start-ComfyUI
        Start-ComfyUI --listen 0.0.0.0
    #>
    [CmdletBinding()]
    param(
        [string]$ComfyUIPath = "D:/WebUI/ComfyUI",
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    try {
        $pythonPath = Join-Path $ComfyUIPath ".venv/Scripts/python.exe"
        $mainScript = Join-Path $ComfyUIPath "main.py"
        
        if (-not (Test-Path $pythonPath)) {
            Write-StatusMessage "Python virtual environment not found at: $pythonPath" "Error"
            return
        }
        
        if (-not (Test-Path $mainScript)) {
            Write-StatusMessage "ComfyUI main.py not found at: $mainScript" "Error"
            return
        }
        
        Write-StatusMessage "Starting ComfyUI..." "Info"
        
        if ($Arguments) {
            & $pythonPath $mainScript @Arguments
        } else {
            & $pythonPath $mainScript
        }
    }
    catch {
        Write-StatusMessage "Error launching ComfyUI: $($_.Exception.Message)" "Error"
    }
}

function Start-OllamaApp {
    <#
    .SYNOPSIS
        Launches Ollama application.
    #>
    [CmdletBinding()]
    param()
    
    try {
        $ollamaPath = "C:\Users\maith\AppData\Local\Programs\Ollama\ollama app.exe"
        
        if (-not (Test-Path $ollamaPath)) {
            Write-StatusMessage "Ollama app not found at: $ollamaPath" "Error"
            return
        }
        
        Start-Process -FilePath $ollamaPath
        Write-StatusMessage "Ollama app started successfully" "Success"
    }
    catch {
        Write-StatusMessage "Error launching Ollama app: $($_.Exception.Message)" "Error"
    }
}

function Start-FileExplorer {
    <#
    .SYNOPSIS
        Opens File Explorer at specified path.
    
    .DESCRIPTION
        Launches Windows File Explorer at the given path or current directory.
    
    .PARAMETER Path
        Path to open in File Explorer.
    
    .EXAMPLE
        Start-FileExplorer
        Start-FileExplorer "C:\Projects"
    #>
    [CmdletBinding()]
    param(
        [string]$Path = (Get-Location).Path
    )
    
    try {
        Start-Process -FilePath "explorer.exe" -ArgumentList $Path
        Write-StatusMessage "File Explorer opened at: $Path" "Success"
    }
    catch {
        Write-StatusMessage "Error opening File Explorer: $($_.Exception.Message)" "Error"
    }
}

# Ollama Quick Run
function Start-OllamaRun {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    $scriptPath = "C:\Users\maith\OneDrive\Documents\PowerShell\Scripts\orun.py"
    & python $scriptPath @Arguments
}

# ============================================
# Aliases - Organized by Category
# ============================================

# Command Discovery
Set-Alias -Name which -Value Find-CommandPath
Remove-Alias -Name where -ErrorAction SilentlyContinue -Force
Set-Alias -Name where -Value Find-CommandPath

# Directory Listing
Set-Alias -Name ll -Value Get-DirectoryListDetailed
Set-Alias -Name tree -Value Get-DirectoryTree
Set-Alias -Name tt -Value Get-DirectoryTree

# System Information
Set-Alias -Name neofetch -Value Show-SystemInfo
Set-Alias -Name sysinfo -Value Show-SystemInfo

# Android Tools
Set-Alias -Name sy -Value Start-ScreenMirror
Set-Alias -Name mirror -Value Start-ScreenMirror
Set-Alias -Name otg -Value Start-OTGMode

# Profile Management
Set-Alias -Name prof -Value Open-PowerShellProfile
Set-Alias -Name psh -Value Open-PowerShellHistory
Set-Alias -Name clh -Value Clear-PowerShellHistory
Set-Alias -Name aprof -Value Open-AllUsersProfile
Set-Alias -Name cprof -Value Open-CurrentUserProfile


# Command Replacements
Set-Alias -Name ls -Value eza -Option AllScope
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim
Set-Alias -Name py -Value python
Set-Alias -Name man -Value tldr

# System Power
Set-Alias -Name reboot -Value Restart-Computer
Set-Alias -Name shutdown -Value Stop-Computer

# WSL
Set-Alias -Name zsh -Value wsl
Set-Alias -Name arch -Value wsl
Set-Alias -Name bash -Value wsl

# Editors
Set-Alias -Name co -Value code
Set-Alias -Name vscode -Value code

# Applications
Set-Alias -Name comfyui -Value Start-ComfyUI
Set-Alias -Name ogui -Value Start-OllamaApp
Set-Alias -Name open -Value Start-FileExplorer
Set-Alias -Name orun -Value Start-OllamaRun