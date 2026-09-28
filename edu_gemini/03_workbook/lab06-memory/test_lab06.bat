@echo off
setlocal
rem ==========================================================
rem   Lab 06: decision-memory Windows Test Runner
rem ==========================================================

cd /d "%~dp0"

echo === Lab 06: decision-memory Testing ===
echo.

set "WORK_DIR=starter"
if "%~1"=="solution" set "WORK_DIR=..\solutions\lab06-memory"
if "%~1"=="solutions" set "WORK_DIR=..\solutions\lab06-memory"

cd "%WORK_DIR%"

echo [1/4] Cleaning previous test log...
if exist ".claude\decisions.jsonl" del /f /q ".claude\decisions.jsonl" >nul 2>nul

echo [2/4] Testing decision recording...
if exist "record-decision.bat" (
    call record-decision.bat "test-arch" "Adopt Fail-Closed Hook" "Prevent catastrophic rm -rf"
) else (
    if exist "%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles%\Git\bin\bash.exe" record-decision.sh "test-arch" "Adopt Fail-Closed Hook" "Prevent catastrophic rm -rf"
)
if %errorlevel% neq 0 (
    echo [FAIL] Failed to execute record-decision.
    goto :FAIL
)

echo [3/4] Validating .claude\decisions.jsonl creation...
if not exist ".claude\decisions.jsonl" (
    echo [FAIL] .claude\decisions.jsonl was not created.
    goto :FAIL
)
findstr /C:"Adopt Fail-Closed Hook" ".claude\decisions.jsonl" >nul
if %errorlevel% neq 0 (
    echo [FAIL] Recorded content not found in decisions.jsonl.
    goto :FAIL
)
echo    [PASS] Record verified in decisions.jsonl.

echo [4/4] Checking SKILL.md specification...
set "SKILL_FILE=SKILL.md"
if not exist "%SKILL_FILE%" set "SKILL_FILE=..\..\solutions\lab06-memory\SKILL.md"
if exist "%SKILL_FILE%" (
    findstr /C:"name: decision-memory" "%SKILL_FILE%" >nul
    if %errorlevel% equ 0 echo    [PASS] SKILL.md validated.
)

if exist ".claude" rmdir /s /q ".claude" >nul 2>nul

echo.
echo [SUCCESS] Lab 06 all criteria passed!
set RET=0
goto :FINISH

:FAIL
echo.
echo [FAIL] Lab 06 verification failed.
set RET=1

:FINISH
cd /d "%~dp0"
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
