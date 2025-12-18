# ===================================================================
# Description:
# Sets a custom blank.ico icon for Windows shortcuts
# in order to remove the default shortcut arrow overlay.
# The change can be reverted at any time.
# Author: Hatix Ntsoa
# Usage:
# shortcut.icon.manager.ps1 set     → Remove shortcut arrow
# shortcut.icon.manager.ps1 revert  → Restore default arrow
# ===================================================================

# Requires Administrator privileges
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("set", "revert")]
    [string]$Action
)

# Enable UTF-8 for proper emoji display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =================================================
# Colored Tags (using Write-Host with foreground colors)
# =================================================
$ERR  = "[ERROR]"   # Red
$INF  = "[INFO]"    # Blue
$DONE = "[DONE]"    # Green
$BANNER = "[BANNER]"# Blue

# ====================================================
# Banner ASCII Art
# ====================================================
$bannerLines = @"
 _     _             _      _
| |__ | | __ _ _ __ | | __ (_) ___ ___  _ __
| '_ \| |/ _` | '_ \| |/ / | |/ __/ _ \| '_ \
| |_) | | (_| | | | |   < _| | (_| (_) | | | |
|_.__/|_|\__,_|_| |_|_|\_(_)_|\___\___/|_| |_|
                                   @hatixntsoa
"@ -split "`n"

Clear-Host
foreach ($line in $bannerLines) {
    Write-Host $line.TrimStart() -ForegroundColor Blue
}
Write-Host ""

# ===================================================
# Auto-elevate if not running as Administrator
# ===================================================
function Test-Admin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $current
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "$INF Elevating to Administrator." -ForegroundColor Blue
    Start-Sleep -Seconds 1

    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $Action")
        Write-Host "$DONE Successfully elevated to Administrator!" -ForegroundColor Green
        Write-Host ""
        exit 0
    }
    catch {
        Write-Host "$ERR You need administrator privileges to run this script." -ForegroundColor Red
        exit 1
    }
}

# =================================================
# Helper function for consistent delays and messages
# =================================================
function Show-Info   { param([string]$msg) Write-Host "$INF $msg" -ForegroundColor Blue;  Start-Sleep -Seconds 1 }
function Show-Done   { param([string]$msg) Write-Host "$DONE $msg" -ForegroundColor Green; Write-Host "" }
function Show-Error  { param([string]$msg) Write-Host "$ERR $msg" -ForegroundColor Red;   Write-Host "" }

# =================================================
# Function: Set custom blank icon (remove arrow)
# =================================================
function Set-Icon {
    Show-Info "Configuring blank.ico."

    $icon_url = "https://blank.hatixntsoa.site/icon/blank.ico"

    # Temporary folder next to the script (same as batch: ..\icon)
    $scriptDir = Split-Path -Parent $PSCommandPath
    $icon_dir = Join-Path (Split-Path -Parent $scriptDir) "icon"
    if (-not (Test-Path $icon_dir)) { New-Item -ItemType Directory -Path $icon_dir | Out-Null }
    $downloaded_icon = Join-Path $icon_dir "blank.ico"

    # Safe permanent location in user's Pictures folder
    $safe_dir = Join-Path $env:USERPROFILE "Pictures\blank"
    $safe_icon = Join-Path $safe_dir "blank.ico"

    # Check if icon already exists in safe location
    if (Test-Path $safe_icon) {
        Show-Done "Icon already stored."
    }
    else {
        Show-Info "Downloading blank.ico"

        try {
            Invoke-WebRequest -Uri $icon_url -OutFile $downloaded_icon -UseBasicParsing | Out-Null
            if (-not (Test-Path $downloaded_icon)) { throw }
            Show-Done "blank.ico downloaded."
        }
        catch {
            Show-Error "Failed to download icon from $icon_url."
            exit 1
        }

        if (-not (Test-Path $safe_dir)) { New-Item -ItemType Directory -Path $safe_dir | Out-Null }

        Show-Info "Copying blank.ico to $safe_dir."
        Start-Sleep -Seconds 1
        Copy-Item $downloaded_icon $safe_icon -Force | Out-Null
        Show-Done "blank.ico copied."
    }

    # Add registry entry using the safe local path
    Show-Info "Adding registry entry."
    Start-Sleep -Seconds 1

    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "$safe_icon" /f | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Show-Error "Failed to add registry entry. Please ensure you have admin rights."
    }
    else {
        Show-Done "Registry entry added successfully!"
    }

    # Restart Explorer
    Start-Sleep -Seconds 1
    Show-Info "Restarting Windows Explorer."

    # Force kill all explorer.exe processes (exact equivalent of taskkill /f /im explorer.exe >nul 2>&1)
    taskkill /f /im explorer.exe > $null 2>&1

    # Immediate restart (exact equivalent of start explorer.exe)
    & explorer.exe

    # Wait 1 second without breaking (exact equivalent of timeout /t 1 /nobreak >nul)
    Start-Sleep -Seconds 1

    Show-Done "Windows explorer restarted."

    # Cleanup temporary files
    Start-Sleep -Seconds 1
    Show-Info "Cleaning up temporary files."
    if (Test-Path $downloaded_icon) { Remove-Item $downloaded_icon -Force -ErrorAction SilentlyContinue }
    if (Test-Path $icon_dir) { Remove-Item $icon_dir -Recurse -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 1
    Show-Done "Temporary files cleaned."

    Start-Sleep -Seconds 1
    Write-Host "$INF Windows shortcut arrow icon removed successfully!" -ForegroundColor Blue
}

# =================================================
# Function: Revert to default arrow
# =================================================
function Revert-Icon {
    Show-Info "Restoring windows arrow icon."
    Write-Host ""

    Start-Sleep -Seconds 1
    Show-Info "Removing registry entry."
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f | Out-Null
    Start-Sleep -Seconds 1
    Show-Done "Registry entry removed."

    Start-Sleep -Seconds 1
    Show-Info "Restarting Windows Explorer."

    # Force kill all explorer.exe processes (exact equivalent of taskkill /f /im explorer.exe >nul 2>&1)
    taskkill /f /im explorer.exe > $null 2>&1

    # Immediate restart (exact equivalent of start explorer.exe)
    & explorer.exe

    # Wait 1 second without breaking (exact equivalent of timeout /t 1 /nobreak >nul)
    Start-Sleep -Seconds 1

    Show-Done "Windows explorer restarted."
    Start-Sleep -Seconds 1
    Write-Host "$INF Windows shortcut arrow icon restored!" -ForegroundColor Blue
    Start-Sleep -Seconds 1
}

# =================================================
# Execute requested action
# =================================================
if ($Action -eq "set") {
    Set-Icon
}
elseif ($Action -eq "revert") {
    Revert-Icon
}

exit
