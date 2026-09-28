---
name: explain-module
description: |
  낯선 모듈/디렉터리를 코드 근거와 함께 설명한다. 진입점 → 데이터 흐름 → 외부 의존 →
  위험 지점 순서로 읽고, 모든 주장에 file:line을 단다. 코드는 수정하지 않는다.
  Use when asked to "이 모듈 설명해줘", "이 폴더 어떻게 동작해", "코드 구조 파악",
  "explain this module", or "how does X work".
  Proactively invoke when the user is about to change code in a directory they say they don't know.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# /explain-module — 근거 있는 모듈 설명

## Iron Law

**file:line 근거 없는 주장은 쓰지 않는다.**
확인하지 못한 것은 "추정:"으로 시작하고 확인 방법을 적는다.

Bash는 `git log`, `wc -l`, `ls` 같은 **읽기 전용** 명령에만 쓴다. 파일을 만들거나 바꾸지 않는다.

## Phase 1: 범위 확정
1. 대상 경로가 없거나 모호하면 AskUserQuestion으로 **하나만** 묻는다: "어느 디렉터리/파일인가요?"
2. 규모 측정: `git ls-files <path> | wc -l`
3. 파일이 **40개 초과**면 멈추고 AskUserQuestion:
   ```
   <path>에 파일이 N개라 한 번에 설명하면 얕아집니다.
   A) 하위 디렉터리 하나로 좁히기 — [후보 3개 제시]
   B) 공개 진입점만 설명 (내부 구현 생략)
   C) 그대로 전체 진행
   ```
출력물: **"범위: <path>, 파일 N개, 모드: 전체|진입점만"**

## Phase 2: 진입점
- export / main / route 등록 / CLI 파싱 위치를 Grep으로 찾는다.
출력물: 진입점 목록 (각각 file:line)

## Phase 3: 데이터 흐름
- 진입점 1~3개에서 호출을 따라간다. 최대 깊이 4.
- 따라가다 범위 밖으로 나가면 "외부:"로 표시하고 더 들어가지 않는다.
출력물: `A (file:line) → B (file:line) → …` 형식의 흐름

## Phase 4: 외부 의존 · 위험 지점
- import 중 범위 밖 모듈, 전역 상태, I/O(파일·네트워크·DB), TODO/FIXME, 테스트 유무
출력물: 표

## 중단 조건
- 같은 심볼의 정의를 **3번** 찾아도 못 찾으면(동적 디스패치, 코드 생성 등) 추적을 멈추고 "추적 불가: 이유"로 기록한다. 추측으로 메우지 않는다.

## Red flags
- file:line 없이 "보통 이런 구조는…"이라고 쓰고 있다 → 멈추고 Read.
- 설명이 코드보다 길어지고 있다 → 범위가 너무 넓다. Phase 1로.

## 최종 보고
```
MODULE REPORT: <path>
════════════════════════════════════
한 줄 요약:   ...
진입점:       file:line, ...
데이터 흐름:  A → B → C (각 file:line)
외부 의존:    ...
위험 지점:    ... (file:line)
추적 불가:    ... (없으면 "없음")
Status:       DONE | DONE_WITH_CONCERNS | BLOCKED
════════════════════════════════════
```
- DONE: 모든 주장에 근거 있음
- DONE_WITH_CONCERNS: "추정:" 항목이나 추적 불가 항목이 있음
- BLOCKED: 범위를 확정하지 못함
