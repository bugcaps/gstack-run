# 02-3. 상태 파일 + deny-tier hook: `/freeze`

**원본:** `gstack/freeze/SKILL.md.tmpl` (1–31, 43–70행), `gstack/freeze/bin/check-freeze.sh` (169줄 중 1–72, 93–112, 151–169행)

## 이 발췌에서 배울 것
1. **스킬 본문이 상태 파일을 쓰고, hook이 그 파일을 읽는** 2단 구조.
2. careful(ask-tier)과 freeze(deny-tier)는 실패 시 극성이 **반대**다 — 의도된 설계.
3. `trap EXIT` 백스톱으로 "예상 못 한 죽음"까지 fail-closed로 만든다.

## ① 스킬: 하나의 hook을 두 도구에 연결 (`freeze/SKILL.md.tmpl` 14–30행)

```yaml
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
# 📝 경계 디렉터리를 사용자에게 물어야 하므로 AskUserQuestion 포함
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
sensitive: true
```

## ② 스킬 본문: 사용자 입력 → 상태 파일 기록 (43–70행)

~~~~markdown
## Setup

Ask the user which directory to restrict edits to. Use AskUserQuestion:

- Question: "Which directory should I restrict edits to? Files outside this path will be blocked from editing."
- Text input (not multiple choice) — the user types a path.

Once the user provides a directory path:

1. Resolve it to an absolute path:
```bash
FREEZE_DIR=$(cd "<user-provided-path>" 2>/dev/null && pwd)
echo "$FREEZE_DIR"
```

2. Ensure trailing slash and save to the freeze state file:
```bash
FREEZE_DIR="${FREEZE_DIR%/}/"
eval "$(~/.claude/skills/gstack/bin/gstack-paths)"
STATE_DIR="$GSTACK_STATE_ROOT"
mkdir -p "$STATE_DIR"
echo "$FREEZE_DIR" > "$STATE_DIR/freeze-dir.txt"
echo "Freeze boundary set: $FREEZE_DIR"
```

Tell the user: "Edits are now restricted to `<path>/`. Any Edit or Write
outside this directory will be blocked. To change the boundary, run `/freeze`
again. To remove it, run `/unfreeze` or end the session."
~~~~

📝 `<user-provided-path>` 같은 **자리표시자를 모델이 채우도록** 지시한다. 끝의 `/`는 `/src`가 `/src-old`와 매칭되는 것을 막는다(원본 93행 Notes).

## ③ hook: 극성과 백스톱 (`check-freeze.sh` 1–29행)

```bash
#!/usr/bin/env bash
# check-freeze.sh — PreToolUse hook for /freeze skill
# Reads JSON from stdin, checks if file_path is within the freeze boundary.
# Returns a PreToolUse hookSpecificOutput with permissionDecision "deny" to block,
# or {} to allow. The decision MUST be nested under hookSpecificOutput — Claude
# Code ignores a top-level permissionDecision, which silently no-ops the block.
#
# Polarity: freeze is a DENY-tier hook, so an unreadable payload DENIES
# (fail closed). A payload that parses but has no file_path is a non-file
# tool — allow. This is the opposite edge-handling from careful's ask-tier
# and intentionally so: /guard runs both, and a boundary that fails open is
# not a boundary.
set -euo pipefail

# Deny-tier backstop: any unexpected non-zero death (a failing pipeline under
# set -e, a deleted cwd, EACCES) would otherwise exit with no decision JSON,
# which Claude Code treats as non-blocking — the edit proceeds. Every
# deliberate output below sets _FREEZE_DECIDED first so a late failure after
# a decision never prints a second JSON object.
_FREEZE_DECIDED=""
_freeze_backstop() {
  local rc=$?
  if [ "$rc" -ne 0 ] && [ -z "$_FREEZE_DECIDED" ]; then
    _FREEZE_DECIDED=1
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[freeze] Hook failed unexpectedly (exit %s) - blocked, fail closed. Re-run ./setup or /unfreeze."}}\n' "$rc"
    exit 0
  fi
}
trap _freeze_backstop EXIT
# 📝 hook이 JSON 없이 죽으면 Claude Code는 "막지 않음"으로 처리한다.
# 📝    trap으로 어떤 비정상 종료든 deny JSON을 내도록 보장.
```

## ④ 상태 파일 읽기 (51–72행)

```bash
# Locate the freeze directory state file. The writer (/freeze via
# gstack-paths) and this reader MUST resolve the same root or the boundary
# fails open: with GSTACK_HOME set, /freeze wrote freeze-dir.txt under
# GSTACK_HOME while this hook read $HOME/.gstack, found nothing, and allowed
# everything (#1459, #1509). gstack_hook_state_root mirrors gstack-paths.
# ... (생략: 헬퍼 버전 확인 — 56–63행) ...
STATE_DIR="$(gstack_hook_state_root; printf x)"; STATE_DIR="${STATE_DIR%x}"
FREEZE_FILE="$STATE_DIR/freeze-dir.txt"

# If no freeze file exists, allow everything (not yet configured)
if [ ! -f "$FREEZE_FILE" ]; then
  _FREEZE_DECIDED=1
  echo '{}'
  exit 0
fi
# 📝 파일이 없으면 허용 → /unfreeze가 파일만 지우면 되는 이유
```

## ⑤ 판정 (93–112, 151–169행)

```bash
# Extract file_path from tool_input with the shared real-JSON parser.
set +e
FILE_PATH=$(gstack_hook_extract_field "$INPUT" file_path)
EXTRACT_RC=$?
set -e

# Unparseable payload (or no parser available): DENY. A boundary hook that
# allows what it cannot read is not a boundary.
if [ "$EXTRACT_RC" -ne 0 ] && [ -n "$INPUT" ]; then
  gstack_hook_decision deny "[freeze] Could not parse the tool payload to check the freeze boundary. Blocked (fail closed). Freeze boundary: $FREEZE_DIR"
  _FREEZE_DECIDED=1
  exit 0
fi
# ... (생략: 필드 없음 허용, 절대경로화, 심볼릭 링크 해석 — 107–149행) ...

# Check: does the file path start with the freeze directory?
case "$FILE_PATH" in
  "${FREEZE_DIR}/"*|"${FREEZE_DIR}")
    # Inside freeze boundary — allow
    _FREEZE_DECIDED=1
    echo '{}'
    ;;
  *)
    # Outside freeze boundary — deny
    # Log hook fire event (shared helper respects GSTACK_HOME)
    gstack_hook_log_fire freeze boundary_deny

    # The reason is JSON-encoded by the shared helper. Never interpolate paths
    # into hand-built JSON: a path containing a quote or newline produced
    # malformed JSON here, and the deny silently no-oped.
    gstack_hook_decision deny "[freeze] Blocked: $FILE_PATH is outside the freeze boundary ($FREEZE_DIR). Only edits within the frozen directory are allowed."
    _FREEZE_DECIDED=1
    ;;
esac
```

📝 원본 문서의 솔직한 한계 표기(`freeze/SKILL.md.tmpl` 95행): *"This prevents accidental edits, not a security boundary — Bash commands like `sed` can still modify files outside the boundary"*.

## 스킬 제작자를 위한 교훈
- 상태가 필요한 스킬 = **스킬 본문이 쓰고 hook이 읽는 파일**. 해제는 파일 삭제로 충분하다.
- hook마다 실패 극성을 정하라: 경고형은 `ask`, 경계형은 `deny`. 문서에 이유를 적어라.
- `trap … EXIT` 백스톱 + "결정 완료" 플래그로 JSON이 0개나 2개 나가는 것을 막아라.
- 한계(여기선 Bash 우회 가능)를 **스킬 문서에 정직하게** 적어라.

## 직접 해보기
워크북 **[labs/02-hook-guard](../../workbook/labs/02-hook-guard/)**: `.env` 파일 Edit/Write를 deny하는 hook 스킬을 freeze 구조로 만들어 보기.
