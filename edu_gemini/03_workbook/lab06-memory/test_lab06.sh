#!/usr/bin/env bash
# Lab 06 결정 메모리 검증 테스트 러너 (Bash)
set -euo pipefail

WORK_DIR="${1:-starter}"
if [ "$WORK_DIR" = "solution" ] || [ "$WORK_DIR" = "solutions" ]; then
  WORK_DIR="../solutions/lab06-memory"
fi

echo "=== [Lab 06] decision-memory 검증: $WORK_DIR ==="

cd "$WORK_DIR"
rm -f .claude/decisions.jsonl

bash record-decision.sh "test-arch" "Adopt Fail-Closed Hook" "Prevent catastrophic rm -rf"

test -f .claude/decisions.jsonl
grep -q "Adopt Fail-Closed Hook" .claude/decisions.jsonl

rm -rf .claude

echo ""
echo "✅ Lab 06 결정 메모리 테스트 100% 통과!"
