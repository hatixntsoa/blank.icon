@echo off
setlocal enabledelayedexpansion


:: ===================================================================
::  Description:
::    Sets a custom blank.ico icon for windows shortcuts
::    in order to ::ove the default shortcut arrow icon.
::    The change can be reverted at any time as well.
::  Author: Hatix Ntsoa
::  Usage:
::    shortcut.icon.manager.bat --set      → Set custom blank.ico icon
::    shortcut.icon.manager.bat --revert   → Revert to default icon
:: ===================================================================


:: =================================================
:: Set the escape character
:: for ANSI color code insertion
:: =================================================

set "ESC="

:: Enabling emoji printing
chcp 65001 >nul


:: =================================================
:: Define color variables
:: =================================================

set "BLUE=%ESC%[34m"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "RESET=%ESC%[0m"


:: =================================================
:: Colored Tags
:: =================================================

set "ERR=[%RED%ERROR%RESET%]"
set "INF=[%BLUE%INFO%RESET%]"
set "DONE=[%GREEN%DONE%RESET%]"
set "BANNER=[%BLUE%BANNER%RESET%]"


:: ====================================================
:: Banner ASCII Art
:: ====================================================

:::      _     _             _      _
:::     | |__ | | __ _ _ __ | | __ (_) ___ ___  _ __
:::     | '_ \| |/ _` | '_ \| |/ / | |/ __/ _ \| '_ \
:::     | |_) | | (_| | | | |   < _| | (_| (_) | | | |
:::     |_.__/|_|\__,_|_| |_|_|\_(_)_|\___\___/|_| |_|
:::                                        @hatixntsoa
:::
:::    

cls
for /f "delims=: tokens=*" %%A in ('findstr /b "::: " "%~f0"') do (
    echo %BLUE%%%A%RESET%
)


:: ===================================================
:: Auto-elevate script if not running as Administrator
:: ===================================================

if "%~1"=="" (
    echo. %INF% Usage:
    echo   .\%~nx0 --set
    echo   .\%~nx0 --revert
    exit /b 1
) else if /i not "%~1"=="--set" if /i not "%~1"=="--revert" (
    echo %ERR% Unknown option "%~1"
    echo.
    echo. %INF% Usage:
    echo   .\%~nx0 --set
    echo   .\%~nx0 --revert
    exit /b 1
)

:check_admin
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo. %INF% Elevating to Administrator.
    timeout /t 1 /nobreak >nul
    powershell -Command ^
        "$ErrorActionPreference = 'Stop';" ^
        "try {" ^
        "    Start-Process '%~f0' -Verb RunAs -ArgumentList '%*';" ^
        "    Write-Host '%DONE% Successfully elevated to Administrator!';" ^
        "    Write-Host ' ';" ^
        "    exit 0;" ^
        "} catch {" ^
        "    Write-Host '%ERR% You need administrator privileges to run this script.';" ^
        "    exit 1;" ^
    "}"
)


:: =================================================
:: Argument handling
:: =================================================

if /i "%~1"=="--set" (
    call :set_icon
    exit /b
) else if /i "%~1"=="--revert" (
    call :revert_icon
    exit /b
)

goto :eof


::==============================================================
:: Function: set_icon
::==============================================================

:set_icon
timeout /t 1 /nobreak >nul
echo. %INF% Configuring blank.ico.
timeout /t 1 /nobreak >nul

:: Define Icon URL Path based on the custom domain
set "icon_url=https://blank.hatixntsoa.site/icon/blank.ico"

:: Define local temporary folder inside the script directory
set "icon_dir=%~dp0..\icon"
if not exist "%icon_dir%" mkdir "%icon_dir%"
set "downloaded_icon=%icon_dir%\blank.ico"

:: Define safe permanent destination under user's Pictures folder
set "safe_dir=%USERPROFILE%\Pictures\blank"
set "safe_icon=%safe_dir%\blank.ico"

:: Check if icon already exists locally
if exist "%safe_icon%" (
    echo. %DONE% Icon already stored.
    echo.
    timeout /t 1 /nobreak >nul
) else (
    :: Download the icon from GitHub using curl
    echo. %INF% Downloading blank.ico
    curl -L -s -o "%downloaded_icon%" "%icon_url%"
    if not exist "%downloaded_icon%" (
        echo %ERR% Failed to download icon from %icon_url%.
        timeout /t 1 /nobreak >nul
        exit /b
    ) else (
        echo. %DONE% blanc.ico downloaded.
        echo.
    )

    :: Ensure the safe folder exists
    if not exist "%safe_dir%" mkdir "%safe_dir%"

    :: Copy the downloaded icon to the safe location
    echo. %INF% Copying blank.ico to %safe_dir%.
    timeout /t 1 /nobreak >nul
    copy /y "%downloaded_icon%" "%safe_icon%" >nul
    echo. %DONE% blank.ico copied.
    echo.
    timeout /t 1 /nobreak >nul
)

:: Add registry entry using the safe local path
echo. %INF% Adding registry entry.
timeout /t 1 /nobreak >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "%safe_icon%" /f >nul 2>nul
timeout /t 1 /nobreak >nul

if %errorlevel% neq 1 (
    echo. %DONE% Registry entry added successfully!
    echo.
) else (
    echo %ERR% Failed to add registry entry. Please ensure you have admin rights.
    echo.
)

:: Restart Explorer to apply changes
timeout /t 1 /nobreak >nul
echo. %INF% Restarting Windows Explorer.
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
timeout /t 1 /nobreak >nul
echo. %DONE% Windows explorer restarted.
echo.
timeout /t 1 /nobreak >nul

:: Cleanup temporary icon folder
echo. %INF% Cleaning up temporary files.
del /f /q "%downloaded_icon%" >nul 2>&1
rd "%icon_dir%" 2>nul
timeout /t 1 /nobreak >nul
echo. %DONE% Temporary files cleaned.
echo.

timeout /t 1 /nobreak >nul
echo. %INF% Windows shortcut array icon removed successfully 🎉
exit /b


::==============================================================
:: Function: revert_icon
::==============================================================

:revert_icon
echo. %INF% Restoring windows arrow icon.
echo.
timeout /t 1 /nobreak >nul

:: Remove registry entry
echo. %INF% Removing registry entry.
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f >nul 2>nul
timeout /t 1 /nobreak >nul
echo. %DONE% Registry entry removed.
echo.
timeout /t 1 /nobreak >nul

:: Restart Explorer to apply changes
echo. %INF% Restarting Windows Explorer.
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
timeout /t 1 /nobreak >nul
echo. %DONE% Windows explorer restarted.
echo.
timeout /t 1 /nobreak >nul

echo. %INF% Windows shortcut arrow icon restored 🎉
timeout /t 1 /nobreak >nul
exit /b
goto :eof
