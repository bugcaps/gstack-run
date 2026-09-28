#!/usr/bin/env bash
# Lab 03 워크플로 스킬 검증 테스트 러너 (Bash)
set -euo pipefail

TARGET="${1:-starter/SKILL.md}"
if [ ! -f "$TARGET" ]; then
  if [ -f "SKILL.md" ]; then
    TARGET="SKILL.md"
  elif [ -f "../solutions/lab03-workflow/SKILL.md" ]; then
    TARGET="../solutions/lab03-workflow/SKILL.md"
  fi
fi

echo "=== [Lab 03] module-analyst 검증: $TARGET ==="

echo "1. Iron Law 검사..."
grep -q "Iron Law" "$TARGET"
echo "   [PASS] Iron Law 선언 확인"

echo "2. Phase 1 (조사) 검사..."
grep -q "Phase 1" "$TARGET"
echo "   [PASS] Phase 1 확인"

echo "3. Phase 3 (보고) 검사..."
grep -q "Phase 3" "$TARGET"
echo "   [PASS] Phase 3 확인"

echo "4. 중단(Abort) 안전망 검사..."
grep -qi "Abort" "$TARGET"
echo "   [PASS] Abort 비상 탈출구 확인"

echo ""
echo "✅ Lab 03 워크플로 테스트 100% 통과!"
