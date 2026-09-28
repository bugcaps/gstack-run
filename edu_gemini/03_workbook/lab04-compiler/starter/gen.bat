@echo off
setlocal
rem ==========================================================
rem   Lab 04: Skill Compiler gen.bat (Windows)
rem ==========================================================

cd /d "%~dp0"

where node >nul 2>nul
if %errorlevel% equ 0 (
    node -e "const fs = require('fs'); const path = require('path'); const common = fs.readFileSync('partials/common.md', 'utf8'); if (!fs.existsSync('out')) fs.mkdirSync('out'); fs.readdirSync('src').forEach(name => { const p = path.join('src', name, 'SKILL.md.tmpl'); if (fs.existsSync(p)) { const res = fs.readFileSync(p, 'utf8').replace('{{COMMON_SAFEGUARDS}}', common); const outDir = path.join('out', name); if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, {recursive: true}); fs.writeFileSync(path.join(outDir, 'SKILL.md'), res, 'utf8'); console.log('Wrote ' + path.join(outDir, 'SKILL.md')); } });"
    goto :DONE
)

if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" gen.sh
    goto :DONE
)

powershell -NoProfile -Command "$common = Get-Content 'partials/common.md' -Raw; New-Item -ItemType Directory -Force -Path 'out' | Out-Null; Get-ChildItem 'src' -Directory | ForEach-Object { $p = Join-Path $_.FullName 'SKILL.md.tmpl'; if (Test-Path $p) { $res = (Get-Content $p -Raw).Replace('{{COMMON_SAFEGUARDS}}', $common); $outDir = Join-Path 'out' $_.Name; New-Item -ItemType Directory -Force -Path $outDir | Out-Null; Set-Content -Path (Join-Path $outDir 'SKILL.md') -Value $res -NoNewline; Write-Host ('Wrote ' + (Join-Path $outDir 'SKILL.md')) } }"

:DONE
