#!/usr/bin/env bash
# check-secrets.sh — PreToolUse hook: .env / 키 파일에 대한 Edit·Write를 deny.
# 원본 패턴: gstack/freeze/bin/check-freeze.sh + gstack/careful/bin/hook-extract.sh
#   1) JSON은 진짜 파서로 읽는다 (grep/sed 금지 — 따옴표 이스케이프에서 잘림)
#   2) 파싱 실패·예상 못한 오류 → deny (fail closed)
#   3) 결정은 반드시 hookSpecificOutput 아래에 중첩 (최상위 permissionDecision은 무시됨)
set -euo pipefail

DECIDED=""
backstop() {
  local rc=$?
  if [ "$rc" -ne 0 ] && [ -z "$DECIDED" ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] hook error (exit %s) - fail closed"}}\n' "$rc"
    exit 0
  fi
}
trap backstop EXIT

INPUT=$(cat)

# tool_input.file_path 추출. python3 → node 순서 (python3가 Windows 스토어 스텁이면 node로 넘어감).
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

# 이유 문자열을 JSON 문자열로 인코딩 (printf 보간 금지 — 따옴표가 섞이면 JSON이 깨져 deny가 무시됨)
json_str() {
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$1" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>process.stdout.write(JSON.stringify(s)))' && return 0
  fi
  printf '"%s"' "$(printf '%s' "$1" | tr -cd 'a-zA-Z0-9 ._/:@=+-')"
}

deny() {
  DECIDED=1
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "$(json_str "$1")"
  exit 0
}

set +e
FILE_PATH=$(extract_path)
RC=$?
set -e
[ "$RC" -ne 0 ] && deny "[protect-secrets] tool payload를 파싱할 수 없음 - fail closed"

NORM=${FILE_PATH//\\//}      # Windows 경로(D:\a\.env) → D:/a/.env
BASE=${NORM##*/}

case "$BASE" in
  .env.example|.env.sample|.env.template) ;;   # 예시 파일은 허용
  .env|.env.*|*.pem|*.key|id_rsa*|id_ed25519*|credentials.json)
    deny "[protect-secrets] 비밀 파일 수정 차단: $BASE" ;;
esac

DECIDED=1
echo '{}'
