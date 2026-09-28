#!/usr/bin/env bash
# test-hook.sh — check-secrets.sh 채점기. 사용: bash test-hook.sh <hook 스크립트 경로>
# 각 케이스의 stdin JSON을 hook에 넣고, 출력이 (1) 유효한 JSON이고
# (2) hookSpecificOutput.permissionDecision이 기대값인지 확인한다. ({} = allow)
HOOK=${1:?사용법: bash test-hook.sh path/to/check-secrets.sh}
PASS=0; FAIL=0

decision_of() {  # 출력 JSON → deny | allow | INVALID
  printf '%s' "$1" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);const d=j.hookSpecificOutput&&j.hookSpecificOutput.permissionDecision;process.stdout.write(d||(j.permissionDecision?"TOP-LEVEL(무시됨)":"allow"))}catch(e){process.stdout.write("INVALID")}})'
}

check() {  # check <기대값> <설명> <stdin>
  local out got
  out=$(printf '%s' "$3" | bash "$HOOK" 2>/dev/null)
  got=$(decision_of "$out")
  if [ "$got" = "$1" ]; then PASS=$((PASS+1)); echo "PASS  $2 → $got"
  else FAIL=$((FAIL+1)); echo "FAIL  $2 → 기대 $1, 실제 $got"; echo "      출력: $out"; fi
}

check deny  "Edit .env"                '{"tool_name":"Edit","tool_input":{"file_path":"/proj/.env"}}'
check deny  "Write .env.production"    '{"tool_name":"Write","tool_input":{"file_path":"config/.env.production","content":"X=1"}}'
check deny  "Windows 경로 D:\\proj\\.env" '{"tool_name":"Edit","tool_input":{"file_path":"D:\\proj\\.env"}}'
check deny  "server.key"               '{"tool_name":"Write","tool_input":{"file_path":"certs/server.key"}}'
check deny  "따옴표 포함 경로 a\"b.pem"   '{"tool_name":"Edit","tool_input":{"file_path":"keys/a\"b.pem"}}'
check allow ".env.example (예외)"       '{"tool_name":"Edit","tool_input":{"file_path":"/proj/.env.example"}}'
check allow "src/app.ts"               '{"tool_name":"Edit","tool_input":{"file_path":"src/app.ts"}}'
check allow "environment.ts (오탐 금지)" '{"tool_name":"Edit","tool_input":{"file_path":"src/environment.ts"}}'
check deny  "JSON 아님 → fail closed"   'not json at all'
check deny  "빈 입력 → fail closed"      ''

echo "---- $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
