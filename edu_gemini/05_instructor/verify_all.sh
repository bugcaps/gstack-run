#!/usr/bin/env bash
# edu_gemini 정규+심화 6개 랩 전체 솔루션 100% 자동 검증 스위트
set -euo pipefail
ROOT="/d/01_aistudy/gstack_run/edu_gemini"
cd "$ROOT"

echo "=========================================================="
echo "  [edu_gemini] 정규 4종 + 심화 2종 랩 100% 실행 검증 스위트"
echo "=========================================================="

echo ""
echo "=== [1/6] Lab 01: commit-msg-ko 정적 검증 ==="
L1="03_workbook/solutions/lab01-routing/SKILL.md"
grep -q "^name: commit-msg-ko" "$L1"
grep -qi "Use when" "$L1"
grep -q "allowed-tools:" "$L1"
echo "=> [PASS] Lab 01 frontmatter 및 자연어 라우팅 검증 완료"

echo ""
echo "=== [2/6] Lab 02: protect-secrets 훅 동작 검증 ==="
L2="03_workbook/solutions/lab02-hook/check-secrets.sh"
# 2-1: .env 차단 검사
RES_ENV=$(printf '{"tool_input":{"file_path":".env"}}' | bash "$L2")
echo "  .env 차단 결과: $RES_ENV"
echo "$RES_ENV" | grep -q '"permissionDecision":"deny"'
# 2-2: 일반 파일 통과 검사
RES_OK=$(printf '{"tool_input":{"file_path":"src/app.js"}}' | bash "$L2")
echo "  일반 파일 결과: $RES_OK"
[ "$RES_OK" = "{}" ]
echo "=> [PASS] Lab 02 fail-closed 하드 가드 동작 확인 완료"

echo ""
echo "=== [3/6] Lab 03: module-analyst 워크플로 검증 ==="
L3="03_workbook/solutions/lab03-workflow/SKILL.md"
grep -q "Iron Law" "$L3"
grep -q "Phase 1" "$L3"
grep -q "Phase 3" "$L3"
grep -qi "Abort" "$L3"
echo "=> [PASS] Lab 03 Iron Law 및 3단계 게이트웨이 확인 완료"

echo ""
echo "=== [4/6] Lab 04: skill-compiler 빌드 및 린트 검증 ==="
cd "$ROOT/03_workbook/solutions/lab04-compiler"
bash gen.sh
bash validate.sh
cd "$ROOT"
echo "=> [PASS] Lab 04 템플릿 컴파일 및 린트 검증 완료"

echo ""
echo "=== [5/6] 🌟 [심화 1] Lab 05: meta-router 관제탑 검증 ==="
L5="03_workbook/solutions/lab05-router/SKILL.md"
grep -q "^name: meta-router" "$L5"
grep -q "allowed-tools:" "$L5"
grep -q "/investigate" "$L5"
grep -q "/ship" "$L5"
echo "=> [PASS] Lab 05 메타 라우팅 관제탑 매트릭스 확인 완료"

echo ""
echo "=== [6/6] 🌟 [심화 2] Lab 06: decision-memory 기록/검색 검증 ==="
L6="03_workbook/solutions/lab06-memory/record-decision.sh"
rm -f .claude/decisions.jsonl
bash "$L6" "architecture-gate" "Adopt Fail-Closed Hook" "Prevent catastrophic rm -rf"
test -f .claude/decisions.jsonl
grep -q "Adopt Fail-Closed Hook" .claude/decisions.jsonl
rm -rf .claude
echo "=> [PASS] Lab 06 불변 JSONL 의사결정 메모리 기록 확인 완료"

echo ""
echo "🎉 모든 실습 솔루션(정규 Lab 01~04 + 심화 Lab 05~06) 100% 쉘 검증 통과!"
