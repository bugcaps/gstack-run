@echo off
setlocal
rem ==========================================================
rem   edu_gemini Workbook 6 Labs Verification Runner (Windows)
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
    echo [INFO] Running all 6 labs verification...
    echo.
    "%BASH_EXE%" "%~dp0..\05_instructor\verify_all.sh"
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
