#!/usr/bin/env bash
# Lab 02 모범 답안: check-secrets.sh
set -euo pipefail

DECIDED=""
backstop() {
  local rc=$?
  if [ "$rc" -ne 0 ] && [ -z "$DECIDED" ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] 훅 오류 발생 - fail closed 차단"}}\n'
    exit 0
  fi
}
trap backstop EXIT

INPUT=$(cat)

extract_path() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c 'import sys,json
c=json.loads(sys.stdin.read()).get("tool_input",{}).get("file_path","")
sys.stdout.write(c if isinstance(c,str) else "")' 2>/dev/null && return 0
  fi
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$INPUT" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const c=((JSON.parse(s)||{}).tool_input||{}).file_path||"";process.stdout.write(typeof c==="string"?c:"")}catch(e){process.exit(3)}})' 2>/dev/null && return 0
  fi
  return 1
}

FILE_PATH=$(extract_path) || {
  DECIDED=1
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] JSON 파싱 불가 - fail closed 차단"}}\n'
  exit 0
}

NORM=${FILE_PATH//\\//}
BASE=${NORM##*/}

case "$BASE" in
  .env.example|.env.sample|.env.template) ;;
  .env|.env.*|*.pem|*.key|id_rsa*|credentials.json)
    DECIDED=1
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] 기밀 파일 수정 차단: %s"}}\n' "$BASE"
    exit 0
    ;;
esac

DECIDED=1
echo '{}'
