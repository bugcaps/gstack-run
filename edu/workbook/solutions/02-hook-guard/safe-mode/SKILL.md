---
name: safe-mode
description: |
  위험 명령 경고(/careful) + 비밀 파일 편집 차단(/protect-secrets)을 한 번에 켠다.
  Use when asked to "safe mode", "안전 모드", "prod 작업", or "다 잠가줘".
allowed-tools:
  - Bash
  - Read
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/careful/bin/check-careful.sh"
          statusMessage: "Checking for destructive commands..."
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/protect-secrets/bin/check-secrets.sh"
          statusMessage: "Checking secret files..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/protect-secrets/bin/check-secrets.sh"
          statusMessage: "Checking secret files..."
---

# /safe-mode — careful + protect-secrets

gstack `/guard`(= `/careful` + `/freeze`)와 같은 조합 패턴이다. 새 코드 없이
**이미 있는 hook 스크립트 두 개를 frontmatter에서 묶기만** 한다.

**의존성:** `~/.claude/skills/gstack/careful/`(gstack 설치 시 포함)와
`~/.claude/skills/protect-secrets/`가 모두 설치되어 있어야 한다.

- Bash: `rm -rf`, `git push --force`, `DROP TABLE` 등 → 확인 요청(ask)
- Edit/Write: `.env`, `*.key` 등 → 차단(deny)

사용자에게 두 보호 장치가 켜졌다고 한 줄로 알린다. 끄려면 새 대화를 시작한다.
