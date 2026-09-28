@echo off
setlocal
rem ==========================================================
rem   Lab 06: Solution Record Decision Windows Batch
rem ==========================================================

cd /d "%~dp0"
set "SKILL_NAME=%~1"
set "DECISION=%~2"
set "RATIONALE=%~3"

if not defined SKILL_NAME set "SKILL_NAME=general"
if not defined DECISION (
    echo Usage: %~nx0 [skill_name] [decision] [rationale]
    exit /b 1
)
if not defined RATIONALE (
    echo Usage: %~nx0 [skill_name] [decision] [rationale]
    exit /b 1
)

if not exist ".claude" mkdir ".claude"

where node >nul 2>nul
if %errorlevel% equ 0 (
    node -e "const fs = require('fs'); const rec = { timestamp: new Date().toISOString(), skill: process.argv[1], decision: process.argv[2], rationale: process.argv[3] }; fs.appendFileSync('.claude/decisions.jsonl', JSON.stringify(rec) + '\n'); console.log('[decision-memory] Saved to .claude/decisions.jsonl');" "%SKILL_NAME%" "%DECISION%" "%RATIONALE%"
    goto :DONE
)

if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" record-decision.sh "%SKILL_NAME%" "%DECISION%" "%RATIONALE%"
    goto :DONE
)

echo {"timestamp":"%DATE% %TIME%","skill":"%SKILL_NAME%","decision":"%DECISION%","rationale":"%RATIONALE%"}>> .claude\decisions.jsonl
echo [decision-memory] Saved to .claude\decisions.jsonl

:DONE
