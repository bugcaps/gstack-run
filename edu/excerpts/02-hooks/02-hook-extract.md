# 02-2. hook 공용 헬퍼: `hook-extract.sh`

**원본:** `gstack/careful/bin/hook-extract.sh` (110줄 중 1–90행 발췌)

## 이 발췌에서 배울 것
1. 두 hook이 파서를 각자 복사했다가 **한쪽만 버그 수정되는 drift**가 생겼고, 공용 파일로 해결했다.
2. JSON **읽기**(필드 추출)와 **쓰기**(문자열 인코딩) 모두 진짜 파서를 쓴다.
3. 상태 파일 위치를 **쓰는 쪽과 읽는 쪽이 같은 규칙**으로 계산해야 한다.

## ① 왜 공용 파일인가 (1–9행)

```bash
#!/usr/bin/env bash
# hook-extract.sh — SHARED JSON helpers for gstack PreToolUse hooks.
# Sourced (never executed) by careful/bin/check-careful.sh and
# freeze/bin/check-freeze.sh via a path relative to each hook script.
#
# ONE copy on purpose. These two hooks previously carried separate extractor
# copies; the escaped-quote truncation bug got fixed in careful's copy while
# freeze silently kept the broken one. Any future parsing fix lands here and
# reaches both hooks by construction.
```

## ② 필드 추출: python3 → node 폴백 (11–33행)

```bash
# gstack_hook_extract_field PAYLOAD FIELD
#   Prints tool_input.FIELD when PAYLOAD is valid JSON and the field is a
#   string ("" when absent or non-string). Returns 1 when no parser is
#   available or the payload is not parseable JSON — the CALLER decides the
#   polarity for that case (careful asks, freeze denies).
# 📝 실패 시 "어떻게 할지"는 호출자가 정한다 → 헬퍼는 정책을 모른다(관심사 분리).
#
#   python3 is tried first because it ships with macOS and most Linux distros
#   and is reliably on PATH in a hook environment; node is the fallback.
gstack_hook_extract_field() {
  _ghef_payload="$1"
  _ghef_field="$2"
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$_ghef_payload" | python3 -c 'import sys,json
field = sys.argv[1]
d = json.loads(sys.stdin.read())
c = d.get("tool_input", {}).get(field, "")
sys.stdout.write(c if isinstance(c, str) else "")' "$_ghef_field" 2>/dev/null && return 0
  fi
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$_ghef_payload" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);const c=(j&&j.tool_input&&j.tool_input[process.argv[1]])||"";process.stdout.write(typeof c==="string"?c:"")}catch(e){process.exit(3)}})' "$_ghef_field" 2>/dev/null && return 0
  fi
  return 1
}
```

📝 **Windows 주의:** Windows의 `python3`는 Microsoft Store 안내용 스텁일 수 있다. `command -v`는 성공하지만 실행이 실패하므로 `&& return 0`에 걸리지 않고 node 폴백으로 넘어간다. 둘 다 없으면 `return 1` → 호출자가 fail-closed.
(교재 작성 PC에서 확인함: `python3` 스텁 종료코드 49 → node v22.20.0 폴백 → `rm -rf /tmp/x` 입력에 `ask` JSON이 정상 출력됨.)

## ③ 결정 JSON 만들기 (35–64행)

```bash
# gstack_hook_json_string TEXT
#   Prints TEXT as a JSON string literal (surrounding quotes included),
#   encoding quotes, backslashes, control characters and newlines. Never build
#   hook JSON with printf/sed interpolation: a path containing a quote or a
#   newline produces malformed JSON, and Claude Code silently ignores the
#   whole decision — a deny that no-ops exactly when it matters.
# ... (생략: python3/node/문자 제한 폴백 구현 — 41–52행) ...

# gstack_hook_decision DECISION REASON
#   Emits the full PreToolUse hookSpecificOutput envelope with REASON safely
#   JSON-encoded. DECISION is "ask" or "deny". The decision MUST be nested
#   under hookSpecificOutput — Claude Code ignores a top-level
#   permissionDecision, which silently no-ops the block.
gstack_hook_decision() {
  _ghd_decision="$1"
  _ghd_reason="$2"
  _ghd_encoded=$(gstack_hook_json_string "$_ghd_reason")
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":%s}}\n' "$_ghd_decision" "$_ghd_encoded"
}
# 📝 이 한 함수가 hook 출력 형식의 "단일 진실 공급원". 형식 실수가 원천 차단된다.
```

## ④ 상태 파일 저장 위치 (66–90행)

```bash
# gstack_hook_state_root
#   Print the gstack state root, resolved with EXACTLY the chain bin/gstack-paths
#   uses (GSTACK_STATE_ROOT): GSTACK_HOME, then CLAUDE_PLUGIN_DATA only when
#   CLAUDE_PLUGIN_ROOT names gstack (a CLAUDE_PLUGIN_DATA leaked from another
#   plugin via CLAUDE_ENV_FILE must not redirect our state), then $HOME/.gstack,
#   then a project-local .gstack. Hooks run on every Edit/Bash call, so this is
#   pure bash — never spawn gstack-paths from a hook. The writers (/freeze,
#   /guard, /unfreeze, /investigate) resolve through gstack-paths; a reader that
#   used a different chain failed OPEN whenever GSTACK_HOME was set (#1459).
#   test/hook-scripts.test.ts pins parity against gstack-paths.
# ... (생략: 개행 보존 sentinel 설명 — 76–79행) ...
gstack_hook_state_root() {
  if [ -n "${GSTACK_HOME:-}" ]; then
    printf '%s' "$GSTACK_HOME"
  elif [ -n "${CLAUDE_PLUGIN_DATA:-}" ] && printf '%s' "${CLAUDE_PLUGIN_ROOT:-}" | grep -qi "gstack"; then
    printf '%s' "$CLAUDE_PLUGIN_DATA"
  elif [ -n "${HOME:-}" ]; then
    printf '%s' "$HOME/.gstack"
  else
    printf '%s' ".gstack"
  fi
}
# 📝 우선순위: GSTACK_HOME → (gstack 플러그인일 때) CLAUDE_PLUGIN_DATA → ~/.gstack → ./.gstack
# 📝    기본 설치라면 freeze 경계 파일은 ~/.gstack/freeze-dir.txt
```

## 스킬 제작자를 위한 교훈
- hook이 2개 이상이면 파싱/출력 코드는 **공용 파일 1개**로. 복사본은 반드시 어긋난다.
- JSON 출력은 문자열 보간 금지. 경로에 따옴표 하나만 있어도 결정 전체가 무시된다.
- hook은 매 도구 호출마다 돈다 → **순수 bash로 가볍게**, 서브프로세스 최소화.
- 상태를 "쓰는 스킬"과 "읽는 hook"의 경로 계산을 같게 만들고 테스트로 고정하라(#1459).

## 직접 해보기
워크북 **[labs/02-hook-guard](../../workbook/labs/02-hook-guard/)**: 내 hook에서 `gstack_hook_decision`과 같은 출력 함수를 하나 만들어 모든 결정을 그 함수로만 내보내기.
