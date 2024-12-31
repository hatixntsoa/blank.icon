@echo off
setlocal

REM Ensure the script is run as Administrator
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as Administrator.
    echo Please right-click and select "Run as Administrator."
    pause
    exit /b
)

REM Remove the custom registry entry for the shortcut icon
echo Reverting changes and removing the custom shortcut icon...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f

REM Restart Windows Explorer to apply changes
echo Restarting Windows Explorer to apply changes...
taskkill /f /im explorer.exe
start explorer.exe

echo Registry entry reverted successfully!
pause