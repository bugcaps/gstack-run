#!/usr/bin/env bash
set -e
ROOT="/d/01_aistudy/gstack_run"
cd "$ROOT"

echo "=== [1/4] Lab 2: check-secrets.sh 테스트 ==="
HOOK="edu/workbook/solutions/02-hook-guard/protect-secrets/bin/check-secrets.sh"

echo "테스트 1-1: .env 파일 접근 시 deny 검증"
RES1=$(printf '{"tool_input":{"file_path":".env"}}' | bash "$HOOK")
echo "결과: $RES1"
if echo "$RES1" | grep -q '"permissionDecision":"deny"'; then
  echo "=> SUCCESS: .env가 정상적으로 deny 되었습니다."
else
  echo "=> FAIL: .env가 deny 되지 않았습니다."
  exit 1
fi

echo "테스트 1-2: 일반 파일(src/index.js) 접근 시 allow (빈 JSON '{}') 검증"
RES2=$(printf '{"tool_input":{"file_path":"src/index.js"}}' | bash "$HOOK")
echo "결과: $RES2"
if [ "$RES2" = "{}" ]; then
  echo "=> SUCCESS: 일반 파일 접근 시 올바른 통과 신호 '{}'를 반환했습니다."
else
  echo "=> FAIL: 올바른 통과 신호 '{}'가 아닙니다."
  exit 1
fi

echo ""
echo "=== [2/4] Lab 4: gen.sh 템플릿 빌드 테스트 ==="
cd "$ROOT/edu/workbook/solutions/04-scale-up"
bash gen.sh
echo "=> gen.sh 완료"
test -f out/commit-msg-ko/SKILL.md && echo "=> SUCCESS: out/commit-msg-ko/SKILL.md 생성됨"
test -f out/explain-module/SKILL.md && echo "=> SUCCESS: out/explain-module/SKILL.md 생성됨"

echo ""
echo "=== [3/4] Lab 4: validate.sh 유효성 검증 테스트 ==="
cd "$ROOT/edu/workbook/solutions/04-scale-up"
bash validate.sh
echo "=> SUCCESS: validate.sh 통과"

echo ""
echo "=== [4/4] Lab 4 starter의 fixtures 검증 테스트 ==="
cd "$ROOT/edu/workbook/labs/04-scale-up"
# fixtures에 있는 불량 스킬들을 validate.sh가 의도대로 실패시키는지 확인
set +e
bash validate.sh > /dev/null 2>&1
V_RC=$?
set -e
if [ "$V_RC" -ne 0 ]; then
  echo "=> SUCCESS: starter/fixtures의 의도적인 불량 스킬을 validate.sh가 정확히 감지하여 차단했습니다 (exit: $V_RC)."
else
  echo "=> FAIL: 불량 픽스처가 통과되어 버렸습니다."
  exit 1
fi

echo ""
echo "🎉 모든 실습 솔루션 및 스크립트 실행 검증 100% 통과!"
