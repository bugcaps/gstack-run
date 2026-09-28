#!/usr/bin/env bash
# Lab 04 Starter: validate.sh
set -u
TARGET_DIR="${1:-out}"
ERRS=0

echo "=== 정적 린터 검증 시작: $TARGET_DIR ==="

for skill in "$TARGET_DIR"/*/SKILL.md; do
  [ -f "$skill" ] || continue
  name=$(basename $(dirname "$skill"))
  
  if ! grep -q "^name: $name" "$skill"; then
    echo "   [FAIL] $name: name 필드 불일치"
    ERRS=$((ERRS + 1))
  fi
  
  if ! grep -qi "Use when" "$skill"; then
    echo "   [FAIL] $name: description에 'Use when' 누락"
    ERRS=$((ERRS + 1))
  fi
done

if [ "$ERRS" -eq 0 ]; then
  echo "✅ 모든 스킬 정적 검증 통과!"
  exit 0
else
  echo "❌ $ERRS 개의 결함 발견"
  exit 1
fi
