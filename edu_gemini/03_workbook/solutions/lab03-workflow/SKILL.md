---
name: module-analyst
description: 지정된 디렉토리의 코드 아키텍처와 리스크를 3단계로 분석하여 마크다운 보고서를 작성한다. 코드를 수정하지 않는다. Use when asked to '모듈 분석해줘', '코드 구조 파악해줘', 'analyze module'.
allowed-tools:
  - Bash(git ls-files:*)
  - Bash(wc:*)
  - Read
  - Grep
  - Glob
  - Write
---

# 모듈 아키텍처 분석 스킬 (module-analyst)

# Iron Law
> **분석 단계에서 기존 코드를 임의로 수정하거나 리팩토링하는 행위를 절대 금지한다.**

## Phase 1: 정적 파일 인벤토리 조사
- `Bash(git ls-files:*)`로 대상 폴더의 모든 파일 목록을 수집합니다.
- `wc -l`로 코드 라인 수를 집계합니다.

## Phase 2: 의존성 및 호출 관계 분석
- `Grep`과 `Read`를 사용하여 외부 라이브러리 및 내부 import 관계를 분석합니다.

## Phase 3: 종합 보고서 발행
- 분석 결과를 `MODULE-ANALYSIS.md` 파일로 작성하여 저장합니다.

## 중단 조건 (Abort Condition)
- 대상 경로가 존재하지 않거나 읽기 권한이 없는 경우, 즉시 작업을 중단하고 사용자에게 확인을 요청하세요.
