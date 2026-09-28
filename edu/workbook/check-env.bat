@echo off
chcp 65001 >nul
echo ========================================================
echo   [edu_gemini] gstack 실전 아키텍처 환경 자동 진단기 (Win)
echo ========================================================
echo.

set FAIL=0

:: 1. Git & Bash
echo [1/5] Git 및 Bash 검사 중...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo    [X] Git이 설치되어 있지 않습니다. https://git-scm.com 에서 설치하세요.
    set FAIL=1
) else (
    for /f "tokens=*" %%i in ('git --version') do echo    [OK] %%i
)

:: 2. Node.js
echo.
echo [2/5] Node.js 검사 중...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo    [!] Node.js가 없습니다. Lab 02 Hook JSON 안전 파싱에 필수적입니다.
    set FAIL=1
) else (
    for /f "tokens=*" %%i in ('node -v') do echo    [OK] Node.js %%i
)

:: 3. Python3
echo.
echo [3/5] Python3 런타임 검사...
python -c "import sys; sys.exit(0)" >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version') do echo    [OK] %%i
) else (
    echo    [INFO] Python3 스텁 감지됨 (Node.js 대체 작동하므로 실습 가능)
)

:: 4. 에이전트 CLI
echo.
echo [4/5] 코딩 에이전트 환경 검사...
where claude >nul 2>nul
if %errorlevel% equ 0 (
    echo    [OK] Claude CLI 감지됨
) else (
    echo    [INFO] Claude CLI 미설치 (로컬 검증 스위트로 자체 테스트 가능)
)

:: 5. 실습 디렉토리
echo.
echo [5/5] ~/.claude/skills 디렉토리 점검...
if not exist "%USERPROFILE%\.claude\skills" (
    mkdir "%USERPROFILE%\.claude\skills"
    echo    [OK] %USERPROFILE%\.claude\skills 자동 생성 완료!
) else (
    echo    [OK] %USERPROFILE%\.claude\skills 준비됨
)

echo.
echo ========================================================
if %FAIL% equ 0 (
    echo   🎉 모든 실습 환경 준비 완료! 워크북 실습을 시작하세요.
) else (
    echo   ⚠️ 필수 도구 누락이 있습니다. 상단의 안내를 확인하세요.
)
echo ========================================================
echo.
pause
