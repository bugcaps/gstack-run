# gstack 실전 아키텍처: AI 에이전트 스킬 엔지니어링 & 프로덕션 런타임 마스터 (Syllabus)

- **과정명**: gstack으로 배우는 AI 에이전트 스킬 엔지니어링 (정규 4회차 + 심화 2회차)
- **교재 기준**: Garry Tan의 `gstack` v1.91.1 (Commit `2a113ae7`), MIT License
- **과정 목표**: 단순 프롬프트 엔지니어링을 넘어, **확률적 LLM을 결정적 소프트웨어 시스템(Deterministic Software System)**으로 통제하는 스킬 아키텍처를 마스터한다.

---

## 🎯 학습 로드맵 및 회차별 목표

```
[Part 1: 정규 과정 (단일 스킬 엔지니어링)]
  ├── 1회차: 스킬 해부 & 자연어 라우팅 (Frontmatter 계약 & 카탈로그 탐색)
  ├── 2회차: PreToolUse Hook & 절대 보안 (grep 정규식 취약점 & Fail-Closed)
  ├── 3회차: 워크플로 스킬 & Iron Law (5단계 게이트웨이 & 3-Strike 중단 탈출)
  └── 4회차: 템플릿 컴파일러 & 정적 린터 (gen.sh & validate.sh 빌드 자동화)

[Part 2: 심화 과정 (엔터프라이즈 스킬 플릿 & 런타임)] 🌟
  ├── 5회차: 스킬 관제탑과 모델 오버레이 (gstack-router & {{INHERIT}} 보정 래퍼)
  └── 6회차: 런타임 프로토콜, 메타 스킬 & 메모리 (Degraded 모드, skillify, decisions.jsonl)
```

---

## 🗓️ 상세 회차별 커리큘럼 명세표

| 파트 | 회차 | 주제 | 핵심 개념 및 gstack 원본 소스 | 핸즈온 실습 (Hands-on Lab) |
|---|---|---|---|---|
| **정규** | **1회차** | **스킬 해부 & 자연어 라우팅** | • Boil the Ocean 철학과 48줄짜리 `unfreeze`<br>• 제1원칙: "모델은 본문 전에 이름과 설명만 본다"<br>• 호출되는 description vs 무시되는 description<br>• 최소 권한 원칙 (`allowed-tools`) | **Lab 01**: `commit-msg-ko`<br>• 한국어 커밋 제안 스킬<br>• description 트리거 및 권한 잠금 |
| **정규** | **2회차** | **Hook과 결정적 보안 방어** | • 제2원칙: "프롬프트는 부탁이고, Hook은 강제다"<br>• `PreToolUse` Hook 라이프사이클과 JSON 프로토콜<br>• grep 파싱 참사와 진짜 JSON 파서 (`hook-extract.sh`)<br>• fail-closed 백스톱 트랩 & 레고 블록 컴포지션(`/guard`) | **Lab 02**: `protect-secrets`<br>• .env 및 비밀 키 수정 차단 훅<br>• trap backstop EXIT 안전망 구현 |
| **정규** | **3회차** | **워크플로 스킬 & Iron Law** | • 제3원칙: "NO FIXES WITHOUT ROOT CAUSE"<br>• investigate의 5단계 게이트웨이 상태 머신<br>• 무한 루프 토큰 낭비를 막는 3-Strike 중단 조건<br>• 인간-인-더-루프 (`AskUserQuestion`) 인터페이스 | **Lab 03**: `module-analyst`<br>• 코드베이스 모듈 분석 3단계 워크플로<br>• Iron Law 준수 및 Abort 조건 명세 |
| **정규** | **4회차** | **템플릿 컴파일 & 정적 린터** | • 제4원칙: "공통 블록은 한 곳에서 고친다"<br>• `gen-skill-docs.ts` 마크다운 템플릿 컴파일러<br>• 1,500줄을 200줄로: 점진적 로딩(sections)<br>• 무료 정적 린터(`validate.sh`) vs 유료 LLM eval | **Lab 04**: `skill-compiler`<br>• 마크다운 치환 컴파일러(`gen.sh`)<br>• 픽스처 기반 정적 린터 구축 |
| **심화** | **5회차** | **스킬 관제탑 & 모델 오버레이** | • 제5원칙: "스킬은 공짜가 아니다 (컨텍스트 예산)"<br>• 62개 스킬의 관제탑 메타 라우터 (`gstack-router`)<br>• "오탐이 미탐보다 싸다"는 트래픽 분기 철학<br>• 모델별 잔소리 오버레이(`model-overlays/`) & `{{INHERIT}}` | **Lab 05**: `meta-router`<br>• 다중 스킬 의도 분석 및 관제 라우터<br>• 키워드 충돌 방지 라우팅 매트릭스 |
| **심화** | **6회차** | **런타임 프로토콜, 메타 스킬 & 메모리** | • `STATUS: RUNNING` 시그널과 브라우저 장애 시 Degraded 모드<br>• 세션 실행 기록을 영구 스킬로 굳히는 메타 스킬(`skillify`)<br>• 세션 무상태성(Amnesia)을 치료하는 `decisions.jsonl` 불변 로그 | **Lab 06**: `decision-memory`<br>• 세션 불변 의사결정 기록 스킬<br>• JSONL 로그 추가 및 검색 파이프라인 |
