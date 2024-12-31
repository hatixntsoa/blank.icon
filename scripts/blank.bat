@echo off
setlocal

REM Get the current script directory and remove the trailing backslash if present
set "script_dir=%~dp0"
if "%script_dir:~-1%"=="\" set "script_dir=%script_dir:~0,-1%"

REM Define the path to check for blank.ico one directory above inside the "icon" folder
set "icon_dir=%script_dir%\..\icon"
set "blank_file=%icon_dir%\blank.ico"

REM Check if blank.ico exists in the specified "icon" folder one directory above
if exist "%blank_file%" (
    echo Found blank.ico in the icon folder (%icon_dir%).
    set "file_path=%blank_file%"
) else (
    REM Prompt user for the full path to blank.ico if not found
    :prompt_path
    echo blank.ico not found in the icon folder (%icon_dir%).
    set /p "file_path=Please enter the full path to blank.ico: "

    REM Check if the provided path exists
    if not exist "%file_path%" (
        echo The file "%file_path%" does not exist or the path is incorrect.
        echo Please try again.
        goto :prompt_path
    )

    REM Ensure the file is named blank.ico
    for %%F in ("%file_path%") do (
        if /i not "%%~nxF"=="blank.ico" (
            echo The file must be named blank.ico. Please try again.
            goto :prompt_path
        )
    )
)

REM Add registry entry
echo Adding registry entry...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "%file_path%" /f

REM Check if the operation was successful
if %errorlevel% equ 0 (
    echo Registry entry added successfully!
) else (
    echo Failed to add the registry entry. Please run this script as an administrator.
)

REM Reload Windows Explorer
echo Restarting Windows Explorer...
taskkill /f /im explorer.exe
start explorer.exe

pause