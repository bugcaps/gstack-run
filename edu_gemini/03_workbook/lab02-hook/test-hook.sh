#!/usr/bin/env bash
# Lab 02 자체 검증 테스트 러너
set -u
TARGET="${1:-starter/check-secrets.sh}"

echo "=== [Lab 02] 훅 테스트 시작: $TARGET ==="

echo "1. .env 차단 테스트..."
RES1=$(printf '{"tool_input":{"file_path":".env"}}' | bash "$TARGET")
if echo "$RES1" | grep -q '"permissionDecision":"deny"'; then
  echo "   [PASS] .env 차단 성공!"
else
  echo "   [FAIL] .env가 차단되지 않았습니다: $RES1"
  exit 1
fi

echo "2. 일반 파일(src/app.js) 통과 테스트..."
RES2=$(printf '{"tool_input":{"file_path":"src/app.js"}}' | bash "$TARGET")
if [ "$RES2" = "{}" ]; then
  echo "   [PASS] 일반 파일 정상 통과 ('{}')!"
else
  echo "   [FAIL] 통과 신호가 올바르지 않습니다: $RES2"
  exit 1
fi

echo "✅ Lab 02 테스트 전원 통과!"
