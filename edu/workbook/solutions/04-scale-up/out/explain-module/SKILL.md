---
name: explain-module
description: |
  낯선 모듈을 file:line 근거와 함께 설명한다. 코드는 수정하지 않는다.
  Use when asked to "이 모듈 설명해줘", "코드 구조 파악", or "explain this module".
allowed-tools:
  - Read
  - Grep
  - Glob
---
<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->

# /explain-module

## 공통 규칙 (partials/common.md에서 생성됨)
- 사용자에게는 한국어로 답한다. 코드 식별자는 원문 그대로 둔다.
- 확인하지 않은 사실은 "추정:"으로 시작한다.
- 끝에 `Status: DONE | DONE_WITH_CONCERNS | BLOCKED` 한 줄을 붙인다.

## 절차
1. 범위 확정 → 2. 진입점 → 3. 데이터 흐름 → 4. 외부 의존·위험 지점
