@echo off
setlocal
rem ==========================================================
rem   Lab 04: Solution validate.bat (Windows)
rem ==========================================================

cd /d "%~dp0"
set "TARGET_DIR=%~1"
if not defined TARGET_DIR set "TARGET_DIR=out"

echo === Starting Static Linter Validation: %TARGET_DIR% ===

where node >nul 2>nul
if %errorlevel% equ 0 (
    node -e "const fs = require('fs'); const path = require('path'); const targetDir = process.argv[1]; if (!fs.existsSync(targetDir)) { console.error('Directory not found: ' + targetDir); process.exit(1); } let errs = 0; fs.readdirSync(targetDir).forEach(name => { const skillFile = path.join(targetDir, name, 'SKILL.md'); if (fs.existsSync(skillFile)) { const content = fs.readFileSync(skillFile, 'utf8'); if (!content.includes('name: ' + name)) { console.error('   [FAIL] ' + name + ': name mismatch'); errs++; } if (!content.toLowerCase().includes('use when')) { console.error('   [FAIL] ' + name + ': missing Use when trigger'); errs++; } } }); if (errs === 0) { console.log('All skills passed static validation!'); process.exit(0); } else { console.error(errs + ' errors found.'); process.exit(1); }" "%TARGET_DIR%"
    set RET=%errorlevel%
    goto :FINISH
)

if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" validate.sh "%TARGET_DIR%"
    set RET=%errorlevel%
    goto :FINISH
)

set RET=0

:FINISH
exit /b %RET%
