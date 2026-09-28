# 02-1. PreToolUse hook 해부: `check-careful.sh`

**원본:** `gstack/careful/bin/check-careful.sh` (314줄 중 1–57, 83–95, 181–216, 261–314행 발췌)

## 이 발췌에서 배울 것
1. hook의 입출력 계약: **stdin으로 JSON이 들어오고, stdout으로 결정 JSON을 낸다.**
2. 결정은 반드시 `hookSpecificOutput.permissionDecision` 아래에 **중첩**해야 한다 (최상위에 두면 무시됨).
3. 파싱 실패·헬퍼 누락 같은 예외 상황에서 **fail-closed**(허용하지 않음)로 설계한다.

## ① 입력 받기 + 헬퍼 로드 (1–25행)

```bash
#!/usr/bin/env bash
# check-careful.sh — PreToolUse hook for /careful skill
# Reads JSON from stdin, checks Bash command for destructive patterns.
# Two tiers:
#   HIGH   — a tiny set of catastrophic SIMPLE commands returns "deny"
#            (best-effort advisory hard-stop, not a policy boundary).
#   MEDIUM — the destructive families below return "ask" (always overridable).
# The decision MUST be nested under hookSpecificOutput — Claude Code ignores a
# top-level permissionDecision, which silently no-ops the warning.
set -euo pipefail

# Read stdin (JSON with tool_input)
INPUT=$(cat)
# 📝 Claude Code가 보내는 입력 예: {"tool_input":{"command":"rm -rf /var/data"}, ...}

# Shared JSON helpers (extractor + encoder) — one copy for careful AND freeze.
# See hook-extract.sh for the drift history that motivated the shared file.
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=careful/bin/hook-extract.sh
# bash treats `.` on a MISSING file as fatal non-interactively; a partial
# install must degrade to an ASK (this is the ask-tier hook), never silence.
_HOOK_HELPER="$_HOOK_DIR/hook-extract.sh"
if [ ! -f "$_HOOK_HELPER" ] || ! . "$_HOOK_HELPER" 2>/dev/null; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"[careful] Hook helpers unavailable (broken install?) - cannot safety-check this command. Approve only if you know what it does."}}\n'
  exit 0
fi
# 📝 설치가 깨져도 "조용히 통과"하지 않고 사용자에게 묻는다(ask). exit 0 + JSON 출력이 정석.
```

## ② grep 파싱 우회 버그의 역사 (26–57행)

```bash
# Extract the "command" field value from tool_input with a real JSON parser.
#
# The previous extractor was
#   grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"'
# whose [^"]* stops at the first escaped quote in the JSON string value. Any
# destructive command preceded by a quoted argument was therefore truncated
# away before the pattern checks ever ran:
#
#   git commit -m "wip" && rm -rf /   ->  CMD='git commit -m \'   -> allowed
#   bash -c "rm -rf /"                ->  CMD='bash -c \'         -> allowed
#   echo "x"; rm -rf ~                ->  CMD='echo \'            -> allowed
#
# Parse the payload properly instead, and fail CLOSED when it cannot be parsed
# at all — a hook that gates destructive commands must not allow-by-default on
# unreadable input.
set +e
CMD=$(gstack_hook_extract_field "$INPUT" command)
EXTRACT_RC=$?
set -e

# No parser available, or the payload is not parseable JSON. Fail closed.
if [ "$EXTRACT_RC" -ne 0 ] && [ -n "$INPUT" ]; then
  gstack_hook_decision ask "[careful] Could not parse the tool payload to safety-check this command. Approve only if you know what it does."
  exit 0
fi

# Parsed fine, but there is genuinely no command field (non-Bash payload) — allow.
if [ -z "$CMD" ]; then
  echo '{}'
  exit 0
fi
# 📝 세 갈래를 명확히 구분: (a) 파싱 실패 → ask, (b) 필드 없음 → 허용 '{}', (c) 명령 있음 → 검사 계속
```

📝 **교훈:** JSON을 정규식/grep으로 파싱하지 말 것. 따옴표 하나로 보안 검사가 통째로 무력화됐다.

## ③ 두 단계 판정: HIGH(deny) vs MEDIUM(ask) (83–95행)

```bash
# --- HIGH tier: hard deny (best-effort advisory hard-stop, NOT a policy boundary) ---
# Only SIMPLE commands are eligible: string matching cannot resolve what a
# compound command does (`cd X && git push --force` — whose cwd? which repo?),
# so anything containing ; && || | or a newline falls through to the MEDIUM ask
# families below — conservative failure = ask, never guess.
# --force-with-lease is deliberately NOT matched here (it is the safe variant).
# curl|sh stays MEDIUM/allow territory: hard-denying it would block legitimate
# installer flows, including gstack's own setup pattern.
_IS_SIMPLE=1
case "$CMD" in
  *';'*|*'&&'*|*'||'*|*'|'*|*$'\n'*) _IS_SIMPLE=0 ;;
esac
# ... (생략: rm 루트 대상 토큰 분석, default 브랜치 force-push 판정 — 96–179행) ...
```

📝 확실할 때만 deny, 애매하면 ask. **오탐으로 정상 작업을 막는 비용**도 설계에 포함한다.

## ④ 안전 예외는 "전체 명령"과 매칭 (181–206행 중 발췌)

```bash
# --- Check for safe exceptions (one standalone rm of build artifacts) ---
# Match the complete command. Parsing only the last rm is unsafe because shell
# syntax or comments can hide an earlier destructive command, for example:
#   rm -rf / # rm -rf node_modules
# Unknown syntax fails closed and falls through to the destructive checks.
# ... (생략: 하드닝 상세 주석 — 186–197행) ...
case "$CMD" in
  *$'\n'*) : ;; # multi-line: fall through to the destructive checks
  *)
    if grep -qE '^[[:space:]]*rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[[:space:]]+|--recursive[[:space:]]+)(([^[:space:];&|#(`]*/)?(node_modules|\.next|dist|__pycache__|\.cache|build|\.turbo|coverage)[[:space:]]*)+$' <<< "$CMD" 2>/dev/null; then
      echo '{}'
      exit 0
    fi
    ;;
esac
# 📝 ^…$ 앵커로 "명령 전체가 빌드 산출물 삭제뿐"일 때만 통과. 체인·주석·치환은 통과 불가.
```

## ⑤ 패턴 검사 → 최종 출력 (208–216, 261–266, 308–314행)

```bash
# --- Destructive pattern checks (MEDIUM tier — always overridable) ---
WARN=""
PATTERN=""

# rm -rf / rm -r / rm -R / rm --recursive (capital -R is BSD/macOS recursive)
if grep -qE 'rm\s+(-[a-zA-Z]*[rR]|--recursive)' <<< "$CMD" 2>/dev/null; then
  WARN="Destructive: recursive delete (rm -r). This permanently removes files."
  PATTERN="rm_recursive"
fi
# ... (생략: DROP/TRUNCATE/force-push/reset --hard/checkout ./kubectl/docker — 218–259행, 같은 형태 반복) ...

# --- Additive project patterns ---
# Config can only ADD warn rules, never remove or weaken a baseline family:
# these files are consulted AFTER the hardcoded checks and only when none of
# them matched, so no file content can suppress a baseline warning. One POSIX
# ERE per line; blank lines and #-comments skipped; an invalid regex is
# skipped (never fatal — the hook must not break on a typo in config).
# ... (생략: 패턴 파일 탐색/적용 루프 — 267–306행) ...

# --- Output ---
if [ -n "$WARN" ]; then
  _careful_log_fire "$PATTERN"
  gstack_hook_decision ask "[careful] $WARN"
else
  echo '{}'
fi
# 📝 출력은 딱 두 가지: 결정 JSON(ask) 또는 빈 객체 '{}'(허용). 항상 exit 0.
```

📝 실제로 출력되는 JSON 형태 (`hook-extract.sh` 63행이 생성, 사유 문구 뒷부분은 `...`로 줄임):
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"[careful] Destructive: recursive delete (rm -r). ..."}}
```

## 스킬 제작자를 위한 교훈
- hook 계약: **stdin JSON → stdout JSON, exit 0**. 결정은 `hookSpecificOutput` 안에.
- 예외 경로(파서 없음, 헬퍼 누락, 파싱 실패)마다 명시적 결정을 내려라. 아무것도 출력 안 하면 "통과"로 취급된다.
- 확신 가능한 좁은 경우만 `deny`, 나머지는 `ask`. 사용자 설정은 **추가만 가능, 기본 규칙 약화 불가**.
- 로그에는 명령 내용이 아니라 **패턴 이름만** 남겨라(59행 주석: "pattern name only, never command content").

## 직접 해보기
워크북 **[labs/02-hook-guard](../../workbook/labs/02-hook-guard/)**: `echo '{"tool_input":{"command":"rm -rf /tmp/x"}}' | bash check-careful.sh`로 hook을 단독 실행해 출력 JSON 확인.
