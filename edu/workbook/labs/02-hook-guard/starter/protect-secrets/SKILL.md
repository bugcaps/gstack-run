---
name: protect-secrets
description: |
  TODO: 무엇을 하는지 한 문장 + "Use when ..." 트리거 문장
allowed-tools:
  - Read
hooks:
  PreToolUse:
    # TODO: Edit 과 Write 각각에 matcher를 달고
    #       command: "bash $HOME/.claude/skills/protect-secrets/bin/check-secrets.sh"
    #       를 연결한다. (참고: gstack/freeze/SKILL.md.tmpl)
---

# /protect-secrets

TODO: 켜졌을 때 모델에게 줄 지시
- 무엇이 차단되는지(표)
- 차단되었을 때 어떻게 행동할지 (우회 금지!)
- 어떻게 끄는지
