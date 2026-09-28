#!/usr/bin/env bash
# Lab 01 자체 검증 테스트 러너 (Bash)
set -euo pipefail

TARGET="${1:-starter/SKILL.md}"
if [ ! -f "$TARGET" ]; then
  if [ -f "SKILL.md" ]; then
    TARGET="SKILL.md"
  elif [ -f "../solutions/lab01-routing/SKILL.md" ]; then
    TARGET="../solutions/lab01-routing/SKILL.md"
  fi
fi

echo "=== [Lab 01] commit-msg-ko 검증: $TARGET ==="

echo "1. Frontmatter 구분자 검사..."
grep -q "^---" "$TARGET"
echo "   [PASS] Frontmatter 구분자 확인"

echo "2. name: commit-msg-ko 검사..."
grep -q "^name: commit-msg-ko" "$TARGET"
echo "   [PASS] name 규격 일치"

echo "3. 자연어 트리거(Use when) 검사..."
grep -qi "Use when" "$TARGET"
echo "   [PASS] Use when 트리거 구문 확인"

echo "4. allowed-tools 최소 권한 검사..."
grep -q "allowed-tools:" "$TARGET"
echo "   [PASS] allowed-tools 선언 확인"

echo ""
echo "✅ Lab 01 테스트 100% 통과!"
