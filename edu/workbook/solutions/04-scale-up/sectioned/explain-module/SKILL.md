---
name: explain-module
description: |
  낯선 모듈을 file:line 근거와 함께 설명한다. 코드는 수정하지 않는다.
  Use when asked to "이 모듈 설명해줘", "코드 구조 파악", or "explain this module".
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# /explain-module (sections 버전)

## Iron Law
**file:line 근거 없는 주장은 쓰지 않는다.**

## Section index — 해당 상황이 되면 그때 Read 한다

이 파일은 뼈대다. 아래 단계에 들어갈 때 해당 섹션을 **처음부터 끝까지 Read 한 뒤** 진행한다.
기억에 의존해 진행하지 않는다. 조건이 맞지 않는 섹션은 **아예 읽지 않는다.**

| 언제 | 읽을 파일 |
|---|---|
| Phase 3 시작 (데이터 흐름 추적 — 항상) | `~/.claude/skills/explain-module/sections/flow.md` |
| Phase 4 시작 — **Phase 1에서 I/O·전역 상태가 보였을 때만** | `~/.claude/skills/explain-module/sections/risk.md` |
| 최종 보고 직전 (항상) | `~/.claude/skills/explain-module/sections/report.md` |

## Phase 1: 범위 확정
- 경로가 모호하면 AskUserQuestion으로 하나만 묻는다.
- `git ls-files <path> | wc -l` → 40개 초과면 A) 좁히기 B) 진입점만 C) 전체 중에서 고르게 한다.
- 파일 목록을 훑어 I/O(fs, http, db)·전역 상태가 보이는지 표시한다 → Phase 4 여부 결정
출력물: "범위: <path>, 파일 N개, Phase 4: 필요|생략"

## Phase 2: 진입점
export / main / route / CLI 파싱 위치를 Grep으로 찾는다. 출력물: 진입점 목록 (file:line)
