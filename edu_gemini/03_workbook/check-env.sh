#!/usr/bin/env bash
# 수강생 환경 자동 진단 스크립트 (Bash)
set -u

echo "========================================================"
echo "  [edu_gemini] gstack 실전 아키텍처 환경 자동 진단기 (Bash)"
echo "========================================================"
echo ""

FAIL=0

if command -v git >/dev/null 2>&1; then
    echo "[OK] $(git --version)"
else
    echo "[X] git을 찾을 수 없습니다."
    FAIL=1
fi

if command -v node >/dev/null 2>&1; then
    echo "[OK] Node.js $(node -v)"
else
    echo "[!] Node.js가 없습니다. 2회차 Hook 실습에 필요합니다."
    FAIL=1
fi

if python3 -c 'import sys; sys.exit(0)' 2>/dev/null; then
    echo "[OK] $(python3 --version)"
else
    echo "[INFO] Python3 스텁 감지됨 (Node.js 대체 작동)"
fi

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"
echo "[OK] $SKILLS_DIR 준비 완료"

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "🎉 모든 실습 환경 준비 완료!"
else
    echo "⚠️ 일부 도구가 누락되었습니다."
fi
