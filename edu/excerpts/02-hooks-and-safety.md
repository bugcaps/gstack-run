# 02강. PreToolUse Hook과 절대 보안: The Gatekeeper Pattern

**원본:** `gstack/careful/bin/check-careful.sh` (1–77행, 145–152행), `gstack/careful/bin/hook-extract.sh`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 프롬프트의 한계: 왜 물리적 게이트(Hook)인가?

많은 개발자가 에이전트의 실수를 막기 위해 프롬프트에 다음과 같이 적습니다:
```markdown
절대로 .env 파일은 건드리지 마세요. 프로덕션 데이터베이스는 삭제하지 마세요.
```
하지만 LLM은 **확률적 생성 모델(Probabilistic Model)**입니다. 긴 대화가 이어져 컨텍스트가 밀려나거나, 복잡한 디버깅 과정에서 모델이 추론에 몰입하면 프롬프트의 금지 조항을 잊어버립니다.

gstack의 제2원칙:
> **"프롬프트는 부탁이고, Hook은 강제다. 보안 경계는 LLM 추론 바깥에 둔다."**

---

## 2. PreToolUse Hook의 소스코드 해부 (`check-careful.sh`)

### ① 헬퍼 로드 및 Fail-Closed 백스톱 (1–38행)

```bash
1: #!/usr/bin/env bash
2: # check-careful.sh — PreToolUse hook for /careful skill
3: # Reads JSON from stdin, checks Bash command for destructive patterns.
4: set -euo pipefail
5: 
6: # Read stdin (JSON with tool_input)
7: INPUT=$(cat)
8: 
9: _HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
10: _HOOK_HELPER="$_HOOK_DIR/hook-extract.sh"
11: if [ ! -f "$_HOOK_HELPER" ] || ! . "$_HOOK_HELPER" 2>/dev/null; then
12:   printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"[careful] Hook helpers unavailable (broken install?) - cannot safety-check this command. Approve only if you know what it does."}}\n'
13:   exit 0
14: fi
```

📝 **해설**:
- 11–13행: 보안 헬퍼 파일이 누락되거나 설치가 깨졌을 때, 스크립트는 조용히 통과(Fail-Open)하지 않고 사용자에게 팝업을 띄우는 `ask` 결정을 내립니다. **"모르면 멈춰라(Fail-Closed)"**의 교과서입니다.

---

### ② 정규식 파싱 참사의 역사 (44–69행)

gstack 초기 버전의 치명적인 취약점이 주석에 고스란히 박제되어 있습니다:

```bash
44: # Extract the "command" field value from tool_input with a real JSON parser.
45: #
46: # The previous extractor was
47: #   grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"'
48: # whose [^"]* stops at the first escaped quote in the JSON string value. Any
49: # destructive command preceded by a quoted argument was therefore truncated
50: # away before the pattern checks ever ran:
51: #
52: #   git commit -m "wip" && rm -rf /   ->  CMD='git commit -m \'   -> allowed
53: #   bash -c "rm -rf /"                ->  CMD='bash -c \'         -> allowed
54: #   echo "x"; rm -rf ~                ->  CMD='echo \'            -> allowed
55: #
56: # Parse the payload properly instead, and fail CLOSED when it cannot be parsed at all.
57: set +e
58: CMD=$(gstack_hook_extract_field "$INPUT" command)
59: EXTRACT_RC=$?
60: set -e
61: 
62: # No parser available, or the payload is not parseable JSON. Fail closed.
63: if [ "$EXTRACT_RC" -ne 0 ] && [ -n "$INPUT" ]; then
64:   gstack_hook_decision ask "[careful] Could not parse the tool payload to safety-check this command. Approve only if you know what it does."
65:   exit 0
66: fi
```

📝 **핵심 교훈**:
- 52행을 보십시오. 사용자가 `git commit -m "wip" && rm -rf /`를 쳤을 때, `grep` 정규식은 커밋 메시지의 따옴표(`"wip"`)에서 매칭을 끝내버렸습니다.
- 뒤에 따라붙은 `rm -rf /`는 검사도 안 거치고 그대로 통과되어 시스템을 파괴할 뻔했습니다.
- **철칙: JSON을 절대 정규식이나 grep으로 파싱하지 마라.** 반드시 Node.js나 Python 같은 진짜 파서를 사용해야 합니다.

---

### ③ hookSpecificOutput 중첩 규격

```bash
145: if [ -n "$WARN" ]; then
146:   _careful_log_fire "$PATTERN"
147:   gstack_hook_decision ask "[careful] $WARN"
148: else
149:   echo '{}'
150: fi
```

실제 출력되는 JSON 구조 (`hook-extract.sh` 63행):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "[protect-secrets] 비밀 파일 수정 차단: .env"
  }
}
```

📝 **치명적인 프로토콜 함정**:
- 판정 결과(`permissionDecision`)를 JSON 최상위에 두면 런타임 호스트는 이를 **조용히 무시**하고 명령을 실행해 버립니다!
- 반드시 `hookSpecificOutput` 키 안에 중첩시켜야 유효합니다.
- 또한 명령을 허용(Allow)할 때는 `"allow"`를 출력하는 것이 아니라 **빈 객체 `{}`**를 출력하는 것이 공식 규격입니다 (149행).

---

## 🎯 실습 연결
학생용 워크북 **[lab02-hook](../../03_workbook/lab02-hook/)**: 기밀 파일(.env, *.key) 수정을 0.01초 만에 차단하는 `protect-secrets` 스크립트와 fail-closed 백스톱 트랩을 직접 구현합니다.
