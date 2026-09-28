@echo off
setlocal
rem ==========================================================
rem   Lab 02: protect-secrets Hook Windows Test Runner
rem ==========================================================

cd /d "%~dp0"
set "TARGET=%~1"
if not defined TARGET set "TARGET=starter\check-secrets.sh"
if not exist "%TARGET%" (
    if exist "check-secrets.sh" set "TARGET=check-secrets.sh"
    if exist "..\solutions\lab02-hook\check-secrets.sh" set "TARGET=..\solutions\lab02-hook\check-secrets.sh"
)

echo === Lab 02: Hook Testing: %TARGET% ===
echo.

set "BASH_EXE="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_EXE (
    for /f "delims=" %%i in ('where bash 2^>nul') do if not defined BASH_EXE set "BASH_EXE=%%i"
)

if defined BASH_EXE (
    echo [INFO] Running test via Git Bash...
    "%BASH_EXE%" test-hook.sh "%TARGET%"
    set RET=%errorlevel%
    goto :FINISH
)

echo [INFO] Running test via native Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [FAIL] Neither Git Bash nor Node.js found.
    set RET=1
    goto :FINISH
)

node -e "
const fs = require('fs');
const content = fs.readFileSync(process.argv[1], 'utf8');
if (content.includes('.env') && content.includes('deny') && content.includes('hookSpecificOutput')) {
  console.log('   [PASS] Static verification passed (deny + hookSpecificOutput found)');
} else {
  console.error('   [FAIL] Missing security keywords in script');
  process.exit(1);
}
" "%TARGET%"
set RET=%errorlevel%

:FINISH
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
