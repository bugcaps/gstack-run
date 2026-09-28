---
name: commit-msg-ko
description: |
  staged 변경을 읽고 한국어 Conventional Commit 메시지를 제안한다. 커밋은 실행하지 않는다.
  Use when asked to "커밋 메시지 써줘", "이 변경 뭐라고 커밋하지", or "write a commit message".
allowed-tools:
  - Bash
  - Read
---
<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->

# /commit-msg-ko

## 공통 규칙 (partials/common.md에서 생성됨)
- 사용자에게는 한국어로 답한다. 코드 식별자는 원문 그대로 둔다.
- 확인하지 않은 사실은 "추정:"으로 시작한다.
- 끝에 `Status: DONE | DONE_WITH_CONCERNS | BLOCKED` 한 줄을 붙인다.

## 절차
1. `git diff --cached --stat` 과 `git diff --cached` 로 변경을 읽는다. 없으면 멈춘다.
2. `<type>: <요약>` (50자 이내) + "왜" 1~3줄로 메시지를 제안한다.
