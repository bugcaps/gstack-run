# 스킬 제작 실습 워크북 (gstack 기반)

대상: Claude Code **스킬을 직접 만드는 사람**.
교재: `../../gstack/` (gstack v1.91.1, 커밋 `2a113ae7`, MIT) — **읽기만** 하고 수정하지 않습니다.
발췌본: `../excerpts/` (원본 일부에 주석을 단 사본)

## 회차별 랩

| 회차 | 랩 | 만드는 것 | 핵심 개념 | 발췌본 |
|---|---|---|---|---|
| 1 | [01-first-skill](labs/01-first-skill/) | `commit-msg-ko` | frontmatter, description = 라우팅, 최소 allowed-tools | 01-anatomy |
| 2 | [02-hook-guard](labs/02-hook-guard/) | `protect-secrets`, `safe-mode` | PreToolUse hook, fail closed, `hookSpecificOutput`, 조합 | 02-hooks, 03-composition |
| 3 | [03-workflow-skill](labs/03-workflow-skill/) | `explain-module` | Iron Law, 단계별 출력물, 중단 조건, AskUserQuestion | 04-workflow-skill |
| 4 | [04-scale-up](labs/04-scale-up/) | `gen.sh`, sections, `validate.sh` | 템플릿 생성, 필요할 때만 읽기, 스킬 테스트 | 05, 06, 08 |

더 읽을거리: [07-script-backed-skill](../excerpts/07-script-backed-skill/) — `gstack/browser-skills/hackernews-frontpage/` (SKILL.md + script.ts + test + fixtures)

- 참고 답안: [solutions/](solutions/)
- 회차별 퀴즈: [self-check.md](self-check.md)

각 랩 README 구성: **목표 / 배경 / 단계 / 성공 기준 / 막히면**

## 사전 준비 (Windows 기준)

| 도구 | 필요한 곳 | 비고 |
|---|---|---|
| Claude Code | 전 회차 | |
| Git for Windows (Git Bash) | 2·4회차 | hook은 `bash …`로 실행됩니다. 이 워크북의 모든 명령은 Git Bash 기준입니다 |
| Node.js | 2회차 | hook이 JSON 파싱에 사용합니다 (jq 불필요). python3가 있으면 먼저 시도합니다 |
| gstack 설치 | 2회차 조합 과제 | `~/.claude/skills/gstack/careful/bin/check-careful.sh` |
| bun | 선택 | 원본 `bun run gen:skill-docs`, `bun test`를 직접 돌려 볼 때만 |

스킬 위치:
- 개인(모든 프로젝트): `~/.claude/skills/<name>/SKILL.md`
- 프로젝트 전용(저장소에 커밋): `<repo>/.claude/skills/<name>/SKILL.md`
- 스킬을 추가하거나 고친 뒤에는 **새 세션**에서 확인합니다.

## 환경 점검

> 💡 **원클릭 자동 진단 (권장)**:
> - **Windows 탐색기**: `check-env.bat` 파일을 더블클릭하세요.
> - **Git Bash 터미널**: `bash check-env.sh` 명령어를 실행하세요.

직접 수동으로 점검하려면 Git Bash에서:
```bash
claude --version
bash --version | head -1
node --version
python3 -c 'print(1)' || echo "python3 없음/스토어 스텁 → node로 대체되므로 괜찮음"
ls ~/.claude/skills/ 2>/dev/null || mkdir -p ~/.claude/skills
test -f ~/.claude/skills/gstack/careful/bin/check-careful.sh && echo "gstack careful OK" || echo "gstack 미설치 (2회차 조합 과제만 영향)"
echo '{"tool_input":{"command":"rm -rf /tmp/x"}}' | bash ~/.claude/skills/gstack/careful/bin/check-careful.sh
```
마지막 줄의 기대 출력: `{"hookSpecificOutput":{…"permissionDecision":"ask"…}}`

> Windows 주의: 스토어 스텁 `python3`(…\WindowsApps\python3)는 아무것도 하지 않고 종료 코드 49로 끝납니다.
> 워크북 hook은 이 경우 node로 넘어가도록 작성되어 있습니다.
