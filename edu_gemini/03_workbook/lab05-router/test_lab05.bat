@echo off
setlocal
rem ==========================================================
rem   Lab 05: meta-router Windows Test Runner
rem ==========================================================

cd /d "%~dp0"
set "TARGET=%~1"
if not defined TARGET set "TARGET=starter\SKILL.md"
if not exist "%TARGET%" (
    if exist "SKILL.md" set "TARGET=SKILL.md"
    if exist "..\solutions\lab05-router\SKILL.md" set "TARGET=..\solutions\lab05-router\SKILL.md"
)

echo === Lab 05: meta-router Testing: %TARGET% ===
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

echo [2/4] Checking skill name (meta-router)...
findstr /C:"name: meta-router" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] 'name: meta-router' not found.
    goto :FAIL
)
echo    [PASS] Skill name validated.

echo [3/4] Checking allowed-tools definition...
findstr /C:"allowed-tools:" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing 'allowed-tools:'.
    goto :FAIL
)
echo    [PASS] allowed-tools declared.

echo [4/4] Checking core sub-skills routing (/investigate and /ship)...
findstr /C:"/investigate" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing '/investigate' route.
    goto :FAIL
)
findstr /C:"/ship" "%TARGET%" >nul
if %errorlevel% neq 0 (
    echo    [FAIL] Missing '/ship' route.
    goto :FAIL
)
echo    [PASS] Core routing table verified.

echo.
echo [SUCCESS] Lab 05 all criteria passed!
set RET=0
goto :FINISH

:FAIL
echo.
echo [FAIL] Lab 05 verification failed.
set RET=1

:FINISH
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
