#!/usr/bin/env bash
# Lab 06 Starter: record-decision.sh
set -euo pipefail

SKILL_NAME="${1:-general}"
DECISION="${2:-}"
RATIONALE="${3:-}"

if [ -z "$DECISION" ] || [ -z "$RATIONALE" ]; then
  echo "사용법: $0 [스킬명] [결정사항] [이유(WHY)]"
  exit 1
fi

LOG_FILE=".claude/decisions.jsonl"
mkdir -p "$(dirname "$LOG_FILE")"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")

# TODO: 따옴표 이스케이프 후 $LOG_FILE 에 1줄 JSONL 추가
printf '{"timestamp":"%s","skill":"%s","decision":"%s","rationale":"%s"}\n' \
  "$NOW" "$SKILL_NAME" "$DECISION" "$RATIONALE" >> "$LOG_FILE"

echo "✅ [decision-memory] 저장 완료: $LOG_FILE"
