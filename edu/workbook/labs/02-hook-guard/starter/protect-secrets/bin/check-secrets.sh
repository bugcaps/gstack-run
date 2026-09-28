#!/usr/bin/env bash
# check-secrets.sh — PreToolUse hook (starter)
# stdin : {"tool_name":"Edit","tool_input":{"file_path":"..."}}
# stdout: 허용 → {}
#         차단 → {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}
set -euo pipefail

INPUT=$(cat)

# TODO 1: 예상 못한 오류로 스크립트가 죽으면 deny를 출력하는 trap을 건다 (fail closed).
#         힌트: gstack/freeze/bin/check-freeze.sh 의 _freeze_backstop

# TODO 2: tool_input.file_path를 "진짜 JSON 파서"로 꺼낸다. jq는 없다고 가정.
#         python3 → node 순서로 시도, 둘 다 실패하면 return 1.
#         힌트: gstack/careful/bin/hook-extract.sh 의 gstack_hook_extract_field
extract_path() {
  return 1
}

# TODO 3: 파싱 실패 시 deny.

# TODO 4: Windows 경로(D:\proj\.env)도 처리되도록 \ → / 변환 후 basename을 구한다.

# TODO 5: .env.example / .env.sample / .env.template 은 허용,
#         .env / .env.* / *.pem / *.key / id_rsa* / id_ed25519* / credentials.json 은 deny.
#         주의: reason 문자열을 printf로 JSON에 직접 끼워 넣지 말 것 (따옴표가 들어오면 JSON이 깨진다).

echo '{}'
