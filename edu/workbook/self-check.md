# 회차별 이해도 점검

## 1회차 — 스킬 해부

1. Claude Code가 SKILL.md frontmatter에서 실제로 읽는 필드 4개는?
2. description이 짧아야 하는 이유를 gstack `hosts/claude.ts` 주석의 표현으로 설명하면?
3. `description: 커밋 도우미`가 자동 호출에 불리한 이유는?
4. `triggers:`와 `version:`은 Claude Code 표준 필드인가?
5. gstack은 "Use when" 문장이 있는지를 어디서 검사하나? v1.45 이후 무엇이 바뀌었나?

<details><summary>답</summary>

1. `name`, `description`, `allowed-tools`, `hooks`
2. frontmatter는 *"always-on frontmatter catalog every session loads"*. 모든 세션의 컨텍스트에 항상 들어가므로 길이가 곧 비용이다.
3. 사용자가 실제로 칠 문장도, 언제 쓰는지(상황)도 없어서 모델이 판단할 근거가 없다.
4. 아니다. gstack 자체 도구가 쓰는 필드다.
5. `test/skill-validation.test.ts`의 "Skill trigger phrases". v1.45부터 트리거 문장 일부를 본문 `## When to invoke`로 옮겨서, 이제는 frontmatter만이 아니라 파일 전체에서 찾는다.
</details>

## 2회차 — Hook

1. hook이 차단을 표현하는 JSON에서 `permissionDecision`은 어디에 있어야 하나? 최상위에 두면?
2. careful의 옛 JSON 추출기가 `git commit -m "wip" && rm -rf /`를 놓친 이유는?
3. "fail closed"란? careful과 freeze는 파싱 실패 시 각각 무엇을 출력하나?
4. 거절 이유 문자열을 `printf '..."%s"...'`로 JSON에 끼워 넣으면 어떤 문제가 생기나?
5. `/guard`는 새 코드 없이 어떻게 만들어졌나?

<details><summary>답</summary>

1. `hookSpecificOutput.permissionDecision`. 최상위에 두면 Claude Code가 무시해서 차단이 조용히 사라진다(no-op).
2. `grep -o '"command"…"[^"]*"'`가 첫 번째 이스케이프된 따옴표(`\"`)에서 멈춰서, 뒤에 오는 `rm -rf /`가 검사 대상에서 잘려 나갔다.
3. 판단할 수 없으면 막는 쪽으로 결정하는 것. careful(ask 등급 hook)은 `ask`, freeze는 `deny`를 출력한다.
4. 경로에 `"`나 줄바꿈이 있으면 JSON이 깨지고, 깨진 deny는 무시된다. 인코더(`JSON.stringify`, `json.dumps`)로 만들어야 한다.
5. frontmatter `hooks`에 careful hook(Bash)과 freeze hook(Edit·Write)을 함께 연결했다. 스크립트는 형제 스킬 폴더의 것을 그대로 참조한다.
</details>

## 3회차 — 워크플로 스킬

1. investigate의 Iron Law는?
2. 3-strike rule은 언제 발동하고, 발동하면 무엇을 하나?
3. 단계마다 "출력물"을 정해 두면 무엇이 좋은가?
4. investigate가 수정 전에 AskUserQuestion을 하는 수치 기준은?
5. investigate의 완료 상태 3가지와 각각의 의미는?

<details><summary>답</summary>

1. NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
2. 가설 3개가 실패하면 STOP 하고, AskUserQuestion으로 A) 새 가설로 계속 B) 사람에게 에스컬레이션 C) 로깅을 추가하고 대기 중에서 고르게 한다.
3. 출력물이 없으면 단계를 건너뛴 게 드러나고, 다음 단계의 입력이 명확해진다.
4. 수정이 5개 넘는 파일을 건드릴 때(blast radius 확인).
5. DONE(근본 원인 확인, 수정, 회귀 테스트, 전체 테스트 통과) / DONE_WITH_CONCERNS(고쳤지만 완전히 검증하지 못함) / BLOCKED(원인 불명, 에스컬레이션).
</details>

## 4회차 — 규모 키우기

1. gstack에서 사람이 편집하는 파일과 생성되는 파일은 각각 무엇인가?
2. 생성 파일에 들어가는 표시는? 그 위치가 파일 첫 줄이 아닌 이유는?
3. `gen-skill-docs.ts --dry-run`의 용도는?
4. autoplan 뼈대가 섹션을 읽는 규칙 두 가지는?
5. 조건부 섹션을 "아예 읽지 않게" 하는 이유는?

<details><summary>답</summary>

1. `SKILL.md.tmpl`(사람) → `SKILL.md`(생성, 커밋됨)
2. `<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->`. 첫 줄은 frontmatter를 여는 `---`여야 하므로 frontmatter 뒤에 둔다.
3. 메모리에서만 생성해 보고, 커밋된 파일과 다르면 exit 1. 재생성을 깜빡한 경우를 CI에서 잡는다.
4. 해당 상황이 되면 섹션을 처음부터 끝까지 Read 한 뒤 진행한다(기억에 의존하지 않음). 조건이 맞지 않는 섹션은 읽지 않는다.
5. 컨텍스트를 아끼고, 관련 없는 지시가 모델의 행동을 흐리지 않게 하려고.
</details>
