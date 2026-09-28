# Lab 02 — Hook으로 행동을 강제하는 스킬

## 목표
- 프롬프트 부탁("조심해")이 아니라 **PreToolUse hook**으로 도구 호출을 실제로 막는다.
- `.env`·키 파일에 대한 Edit·Write를 deny하는 `protect-secrets` 스킬을 만든다.
- 기존 hook 두 개를 frontmatter에서 묶어 새 스킬을 만든다 (guard 패턴).

## 배경
- 발췌본: [02-hooks](../../../excerpts/02-hooks/), [03-composition](../../../excerpts/03-composition/)
- 원본: `gstack/careful/bin/check-careful.sh`, `gstack/careful/bin/hook-extract.sh`,
  `gstack/freeze/bin/check-freeze.sh`, `gstack/guard/SKILL.md.tmpl`

hook 계약(원본 주석에서 확인한 사실):

| 규칙 | 이유 |
|---|---|
| stdin으로 `{"tool_name":..,"tool_input":{..}}` JSON이 들어온다 | |
| 허용은 `{}` | |
| 결정은 **`hookSpecificOutput` 아래에 중첩** | 최상위 `permissionDecision`은 Claude Code가 무시한다 → 조용히 no-op |
| JSON은 진짜 파서로 읽는다 | 옛 `grep -o '"command"…"[^"]*"'` 추출기는 `git commit -m "wip" && rm -rf /`에서 이스케이프된 따옴표 앞에서 잘려 검사를 통과시켰다 |
| 출력 JSON도 인코더로 만든다 | 경로에 `"`가 있으면 printf 보간 JSON이 깨지고, 깨진 deny는 무시된다 |
| 파싱 실패·오류 → **deny** (fail closed) | 차단용 hook이 기본 허용이면 고장 날 때 뚫린다. (careful은 ask 등급이라 ask로, freeze는 deny로 닫는다) |

## 단계
1. starter 복사
   ```bash
   cp -r starter/protect-secrets ~/.claude/skills/
   ```
2. `bin/check-secrets.sh`의 TODO 1~5를 채운다.
3. 채점기로 확인 (Claude Code 없이 hook만 단독 테스트)
   ```bash
   bash test-hook.sh ~/.claude/skills/protect-secrets/bin/check-secrets.sh
   ```
   수동으로 한 건씩:
   ```bash
   echo '{"tool_name":"Edit","tool_input":{"file_path":".env"}}' | bash ~/.claude/skills/protect-secrets/bin/check-secrets.sh
   echo 'garbage' | bash ~/.claude/skills/protect-secrets/bin/check-secrets.sh   # deny 여야 함
   ```
4. `SKILL.md` frontmatter에 Edit·Write hook을 연결한다.
5. 새 Claude Code 세션에서 `/protect-secrets` → "`.env`에 `DEBUG=1` 추가해줘" → 차단되는지 본다.
6. **조합 과제**: `~/.claude/skills/safe-mode/SKILL.md`를 만들어
   gstack careful hook(Bash) + protect-secrets hook(Edit, Write)을 한 frontmatter에 묶는다.
   `/safe-mode` 후 `rm -rf build-tmp` 요청 → 확인 창, `.env` 수정 요청 → 차단.

## 성공 기준
- [ ] `bash test-hook.sh …` → `10 passed, 0 failed`
- [ ] 빈 입력/JSON 아닌 입력에서 deny (fail closed)
- [ ] 출력의 결정이 `hookSpecificOutput.permissionDecision`에 있다 (채점기가 최상위 필드는 `TOP-LEVEL(무시됨)`으로 표시)
- [ ] `.env.example`, `src/environment.ts`는 허용 (오탐 없음)
- [ ] 실제 세션에서 `.env` 편집이 차단된다
- [ ] `/safe-mode` 하나로 두 보호 장치가 모두 동작한다

## 막히면
- `python3`가 Windows 스토어 스텁이면 아무것도 출력하지 않고 실패한다(종료 코드 49). `&& return 0` 구조로 쓰면 자연스럽게 node로 넘어간다.
- hook이 아예 안 도는 것 같으면: frontmatter의 경로가 `$HOME/.claude/skills/...`인지 확인하세요. (원본 `investigate` 주석: frontmatter hook은 `CLAUDE_SKILL_DIR` 같은 런타임 변수가 생기기 전에 실행되므로 `$HOME` 기준 절대경로를 쓴다.)
- `set -e` 상태에서 추출 실패로 스크립트가 바로 죽으면 `set +e … RC=$? … set -e`로 감싸세요.
- 참고 답안: [`solutions/02-hook-guard/`](../../solutions/02-hook-guard/)
