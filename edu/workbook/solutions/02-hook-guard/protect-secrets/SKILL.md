---
name: protect-secrets
description: |
  비밀 파일 보호 모드. .env, .env.*, *.pem, *.key, id_rsa 같은 비밀 파일에 대한
  Edit·Write를 hook으로 차단한다(.env.example은 허용). Use when asked to
  "비밀 파일 보호", "env 건드리지 마", "protect secrets", or before working in a
  repo that holds credentials.
allowed-tools:
  - Read
hooks:
  PreToolUse:
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

# /protect-secrets — 비밀 파일 편집 차단

보호 모드가 **켜졌다**. 이 세션에서 아래 파일에 대한 Edit·Write는 hook이 deny한다.

| 패턴 | 예 |
|---|---|
| `.env`, `.env.*` | `.env.production` |
| `*.pem`, `*.key` | `certs/server.key` |
| `id_rsa*`, `id_ed25519*`, `credentials.json` | |

예외: `.env.example`, `.env.sample`, `.env.template`

차단되면 사용자에게 어떤 파일이 왜 막혔는지 알리고, 값은 사용자가 직접 바꾸도록 안내한다.
우회(Bash로 `echo > .env` 등)를 시도하지 않는다.

hook은 세션 범위다. 끄려면 새 대화를 시작한다.
