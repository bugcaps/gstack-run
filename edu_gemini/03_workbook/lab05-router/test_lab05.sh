#!/usr/bin/env bash
# Lab 05 메타 라우터 검증 테스트 러너 (Bash)
set -euo pipefail

TARGET="${1:-starter/SKILL.md}"
if [ ! -f "$TARGET" ]; then
  if [ -f "SKILL.md" ]; then
    TARGET="SKILL.md"
  elif [ -f "../solutions/lab05-router/SKILL.md" ]; then
    TARGET="../solutions/lab05-router/SKILL.md"
  fi
fi

echo "=== [Lab 05] meta-router 검증: $TARGET ==="

echo "1. Frontmatter 구분자 검사..."
grep -q "^---" "$TARGET"
echo "   [PASS] Frontmatter 구분자 확인"

echo "2. name: meta-router 검사..."
grep -q "^name: meta-router" "$TARGET"
echo "   [PASS] name 규격 일치"

echo "3. allowed-tools 검사..."
grep -q "allowed-tools:" "$TARGET"
echo "   [PASS] allowed-tools 선언 확인"

echo "4. 하위 스킬 라우팅 매핑 검사..."
grep -q "/investigate" "$TARGET"
grep -q "/ship" "$TARGET"
echo "   [PASS] 핵심 스킬 라우팅 매트릭스 확인"

echo ""
echo "✅ Lab 05 메타 라우터 테스트 100% 통과!"
