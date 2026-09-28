@echo off
setlocal
rem ==========================================================
rem   Lab 03: module-analyst Workflow Windows Test Runner
rem ==========================================================

cd /d "%~dp0"
set "TARGET=%~1"
if not defined TARGET set "TARGET=starter\SKILL.md"
if not exist "%TARGET%" (
    if exist "SKILL.md" set "TARGET=SKILL.md"
    if exist "..\solutions\lab03-workflow\SKILL.md" set "TARGET=..\solutions\lab03-workflow\SKILL.md"
)

echo === Lab 03: module-analyst Testing: %TARGET% ===
echo.

if not exist "%TARGET%" (
    echo [FAIL] Target file %TARGET% not found.
    goto :FAIL
)

echo [1/4] Checking Iron Law compliance...
findstr /C:"Iron Law" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'Iron Law' section.
    goto :FAIL
)
echo    [PASS] Iron Law principle confirmed.

echo [2/4] Checking Phase 1 (Inspection)...
findstr /C:"Phase 1" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'Phase 1'.
    goto :FAIL
)
echo    [PASS] Phase 1 defined.

echo [3/4] Checking Phase 3 (Synthesis / Summary)...
findstr /C:"Phase 3" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'Phase 3'.
    goto :FAIL
)
echo    [PASS] Phase 3 defined.

echo [4/4] Checking Abort / Early Exit trigger...
findstr /I /C:"Abort" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing Abort condition.
    goto :FAIL
)
echo    [PASS] Abort circuit breaker confirmed.

echo.
echo [SUCCESS] Lab 03 all criteria passed!
set RET=0
goto :FINISH

:FAIL
echo.
echo [FAIL] Lab 03 verification failed.
set RET=1

:FINISH
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
