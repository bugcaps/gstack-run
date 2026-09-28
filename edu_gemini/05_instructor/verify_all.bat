@echo off
setlocal
rem ==========================================================
rem   edu_gemini Master Verification Runner
rem ==========================================================

set "BASH_EXE="

if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_EXE (
    if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"
)
if not defined BASH_EXE (
    if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "BASH_EXE=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
)
if not defined BASH_EXE (
    for /f "delims=" %%i in ('where bash 2^>nul') do (
        if not defined BASH_EXE set "BASH_EXE=%%i"
    )
)

if defined BASH_EXE (
    echo [INFO] Git Bash detected: "%BASH_EXE%"
    echo [INFO] Running full test suite: Regular 1-4 and Advanced 5-6
    echo.
    "%BASH_EXE%" "%~dp0verify_all.sh"
    set "RET=%errorlevel%"
    goto :FINISH
)

echo [ERROR] Git Bash was not found on your system.
echo Please install Git for Windows from https://git-scm.com/
set "RET=1"

:FINISH
echo.
if "%~1"=="" pause
exit /b %RET%
