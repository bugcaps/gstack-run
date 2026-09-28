@echo off
setlocal
rem ==========================================================
rem   Lab 04: Skill Compiler Windows Test Runner
rem ==========================================================

cd /d "%~dp0"

echo === Lab 04: Skill Compiler and Linter Testing ===
echo.

set "WORK_DIR=starter"
if "%~1"=="solution" set "WORK_DIR=..\solutions\lab04-compiler"
if "%~1"=="solutions" set "WORK_DIR=..\solutions\lab04-compiler"

echo [1/3] Navigating to %WORK_DIR%...
cd "%WORK_DIR%"

echo [2/3] Executing compilation (gen)...
if exist "gen.bat" (
    call gen.bat
) else (
    if exist "%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles%\Git\bin\bash.exe" gen.sh
)
if %errorlevel% neq 0 (
    echo [FAIL] Code generation failed.
    goto :FAIL
)

echo [3/3] Validating compiled skills (validate)...
if exist "validate.bat" (
    call validate.bat
) else (
    if exist "%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles%\Git\bin\bash.exe" validate.sh
)
if %errorlevel% neq 0 (
    echo [FAIL] Skill validation failed.
    goto :FAIL
)

echo.
echo [SUCCESS] Lab 04 all criteria passed!
set RET=0
goto :FINISH

:FAIL
echo.
echo [FAIL] Lab 04 verification failed.
set RET=1

:FINISH
if "%~2"=="" if "%~1"=="" pause
exit /b %RET%
