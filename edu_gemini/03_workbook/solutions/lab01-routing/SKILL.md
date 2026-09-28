---
name: commit-msg-ko
description: staged 변경(git diff --cached)을 읽고 한국어 Conventional Commit 메시지를 제안한다. 커밋은 실행하지 않는다. Use when asked to '커밋 메시지 써줘', '커밋 메시지 만들어줘', 'write a commit message'.
allowed-tools:
  - Bash(git diff:*)
  - Bash(git status:*)
  - Read
---

# 한국어 커밋 메시지 제안 스킬

staged된 git 변경 사항을 분석하여 한국어 Conventional Commit 메시지를 제안합니다.

## 실행 지침
1. `git diff --cached`를 확인하여 실제 변경점을 파악하세요.
2. 커밋 메시지는 Conventional Commits 규격(`feat:`, `fix:`, `refactor:`, `docs:` 등)을 따릅니다.
3. 2~3개의 대안을 제시하고 사용자의 선택을 기다립니다.
4. 사용자가 명시적으로 승인하기 전까지 `git commit` 명령을 절대 직접 실행하지 마세요.
