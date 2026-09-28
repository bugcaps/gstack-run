# 01-2. frontmatter 해부: `/careful`

**원본:** `gstack/careful/SKILL.md.tmpl` (1–25행 frontmatter, 27–82행 본문 일부), 비교용 `gstack/careful/SKILL.md` (1–4행)

## 이 발췌에서 배울 것
1. frontmatter 필드 7종(name, version, description, triggers, allowed-tools, hooks, sensitive)의 역할.
2. `description`은 설명문이 아니라 **모델이 스킬을 고르는 라우팅 조건**이다.
3. `hooks`를 넣으면 스킬이 "부탁"이 아니라 **강제 장치**가 된다.

## frontmatter (`careful/SKILL.md.tmpl` 1–25행)

```yaml
---
name: careful
# 📝 [name] 디렉터리 이름과 같게. /careful 로 호출된다.
version: 0.1.0
# 📝 [version] 스킬 자체 버전. 동작이 바뀌면 올린다.
description: |
  Safety guardrails for destructive commands. Warns before rm -rf, DROP TABLE,
  force-push, git reset --hard, kubectl delete, and similar destructive operations.
  User can override each warning. Use when touching prod, debugging live systems,
  or working in a shared environment. Use when asked to "be careful", "safety mode",
  "prod mode", or "careful mode". (gstack)
# 📝 [description] 3단 구조
# 📝    ① 첫 문장 = 무엇을 하는가 (카탈로그에 남는 부분)
# 📝    ② "Use when …" = 어떤 상황에서 자동 호출할지 (라우팅 조건)
# 📝    ③ "Use when asked to "…"" = 사용자가 실제로 칠 법한 문구
# 📝    ④ "(gstack)" 태그 = 출처 표시
triggers:
  - be careful
  - warn before destructive
  - safety mode
# 📝 [triggers] 짧은 호출 문구 목록. description의 ③과 역할이 겹치는 보조 신호.
allowed-tools:
  - Bash
  - Read
# 📝 [allowed-tools] 스킬 실행 중 쓸 도구. 최소 권한 원칙 — Edit/Write 없음.
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/careful/bin/check-careful.sh"
          statusMessage: "Checking for destructive commands..."
# 📝 [hooks] 스킬이 활성화된 세션 동안 Bash 도구가 호출될 "때마다"
# 📝    먼저 check-careful.sh가 실행된다. 경로는 $HOME 절대 경로로 고정
# 📝    (investigate 템플릿 121–123행 주석: 런타임 변수는 hook 실행 시점에 없을 수 있음).
sensitive: true
# 📝 [sensitive] 특정 호스트(Factory)용 메타데이터. Claude용 생성본에서는 제거된다.
---
```

### 📝 생성본에서 description은 이렇게 줄어든다 (`careful/SKILL.md` 1–4행)

```yaml
---
name: careful
version: 0.1.0
description: Safety guardrails for destructive commands. (gstack)
```

"Use when…" 문구는 본문 `## When to invoke this skill`로 옮겨진다(01-1 참고).
**직접 스킬을 쓸 때(템플릿 없이)는** 라우팅 문구를 description에 그대로 두는 편이 자동 호출에 유리하다.

## 본문: 모델에게 "무엇이 일어나는지" 알려주기 (`careful/SKILL.md.tmpl` 27–31, 56–63, 82행)

```markdown
# /careful — Destructive Command Guardrails

Safety mode is now **active**. Every bash command will be checked for destructive
patterns before running. If a destructive command is detected, you'll be warned
and can choose to proceed or cancel.

# ... (생략: 텔레메트리 bash 블록, 보호 패턴 표, 안전 예외 목록 — 32–55행) ...

## How it works

The hook reads the command from the tool input JSON, checks it against the
patterns above, and returns a `hookSpecificOutput` payload with
`permissionDecision: "ask"` and a warning reason if a match is found (the
decision must be nested under `hookSpecificOutput` — Claude Code ignores a
top-level `permissionDecision`). You can always override a MEDIUM warning and
proceed.

# ... (생략: HIGH tier, 프로젝트 패턴 설명 — 64–81행) ...

To deactivate, end the conversation or start a new one. Hooks are session-scoped.
```

📝 hook이 실제 차단을 하더라도, 본문은 **모델과 사용자가 상황을 이해하도록** 동작 원리·해제 방법을 설명한다.

## 스킬 제작자를 위한 교훈
- `description` 첫 문장은 "무엇", 이어서 "Use when …"으로 **언제**를 명시하라. 이게 없으면 자동 호출되지 않는다.
- 사용자가 실제로 입력할 구어체 문구("be careful", "prod mode")를 넣어라.
- `allowed-tools`는 필요한 것만. 가드 스킬이 Edit 권한을 가질 이유는 없다.
- hook 경로는 설치 위치 기준 **절대 경로**로 쓰고, 해제 방법(세션 종료)을 본문에 적어라.

## 직접 해보기
워크북 **[labs/01-first-skill](../../workbook/labs/01-first-skill/)**: 내 스킬의 description을 ①②③ 구조로 다시 쓰고, 트리거 문구만으로 호출되는지 확인.
