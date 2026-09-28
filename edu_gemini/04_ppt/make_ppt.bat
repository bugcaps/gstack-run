@echo off
setlocal
rem ==========================================================
rem   edu_gemini 36-Slide PowerPoint Builder (Windows Batch)
rem ==========================================================

cd /d "%~dp0"

echo [INFO] Checking Python runtime...
python -c "import sys; sys.exit(0)" >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python was not found in PATH.
    echo Please install Python 3.10+ from https://www.python.org/
    goto :FAIL
)

echo [INFO] Checking python-pptx dependency...
python -c "import pptx" >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARN] python-pptx library not found. Installing...
    pip install python-pptx
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install python-pptx.
        goto :FAIL
    )
)

echo [INFO] Generating 36-slide presentation (make_ppt.py)...
python make_ppt.py
if %errorlevel% neq 0 (
    echo [ERROR] Slide generation failed.
    goto :FAIL
)

echo.
echo [SUCCESS] gstack-mastery.pptx is ready in %~dp0
goto :DONE

:FAIL
echo [FAIL] Presentation build aborted.
set RET=1
goto :FINISH

:DONE
set RET=0

:FINISH
if "%~1"=="" pause
exit /b %RET%
