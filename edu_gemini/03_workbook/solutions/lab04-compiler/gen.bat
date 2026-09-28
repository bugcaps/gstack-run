@echo off
setlocal
rem ==========================================================
rem   Lab 04: Solution Skill Compiler gen.bat (Windows)
rem ==========================================================

cd /d "%~dp0"

where node >nul 2>nul
if %errorlevel% equ 0 (
    node -e "const fs = require('fs'); const path = require('path'); const commonPath = '../../lab04-compiler/starter/partials/common.md'; if (!fs.existsSync(commonPath)) { console.error('Common partial not found at: ' + commonPath); process.exit(1); } const common = fs.readFileSync(commonPath, 'utf8'); if (!fs.existsSync('out')) fs.mkdirSync('out'); const srcBase = '../../lab04-compiler/starter/src'; if (fs.existsSync(srcBase)) { fs.readdirSync(srcBase).forEach(name => { const p = path.join(srcBase, name, 'SKILL.md.tmpl'); if (fs.existsSync(p)) { const res = fs.readFileSync(p, 'utf8').replace('{{COMMON_SAFEGUARDS}}', common); const outDir = path.join('out', name); if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, {recursive: true}); fs.writeFileSync(path.join(outDir, 'SKILL.md'), res, 'utf8'); console.log('Wrote ' + path.join(outDir, 'SKILL.md')); } }); } else { console.log('No src directory found at ' + srcBase); }"
    goto :DONE
)

if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" gen.sh
    goto :DONE
)

:DONE
