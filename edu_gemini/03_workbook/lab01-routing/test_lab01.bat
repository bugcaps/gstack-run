@echo off
setlocal
rem ==========================================================
rem   Lab 01: commit-msg-ko Windows Test Runner
rem ==========================================================

cd /d "%~dp0"
set "TARGET=%~1"
if not defined TARGET set "TARGET=starter\SKILL.md"
if not exist "%TARGET%" (
    if exist "SKILL.md" set "TARGET=SKILL.md"
    if exist "..\solutions\lab01-routing\SKILL.md" set "TARGET=..\solutions\lab01-routing\SKILL.md"
)

echo === Lab 01: commit-msg-ko Testing: %TARGET% ===
echo.

if not exist "%TARGET%" (
    echo [FAIL] Target file %TARGET% not found.
    goto :FAIL
)

echo [1/4] Checking YAML frontmatter delimiters...
findstr /B "\-\-\-" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Frontmatter delimiter '---' not found at line start.
    goto :FAIL
)
echo    [PASS] Frontmatter delimiters found.

echo [2/4] Checking skill name (commit-msg-ko)...
findstr /C:"name: commit-msg-ko" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] 'name: commit-msg-ko' not found.
    goto :FAIL
)
echo    [PASS] Skill name validated.

echo [3/4] Checking trigger phrases (Use when)...
findstr /I /C:"Use when" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'Use when' trigger phrase in description.
    goto :FAIL
)
echo    [PASS] Natural language triggers found.

echo [4/4] Checking allowed-tools restrictions...
findstr /C:"allowed-tools:" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'allowed-tools:' definition.
    goto :FAIL
)
echo    [PASS] allowed-tools restrictions defined.

echo.
echo [SUCCESS] Lab 01 all criteria passed!
set RET=0
goto :FINISH

:FAIL
echo.
echo [FAIL] Lab 01 verification failed.
set RET=1

:FINISH
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
