# gstack 스킬 아키텍처 실전 교육 자료

이 폴더는 Garry Tan의 `gstack` (v1.91.1, Commit `2a113ae7`, MIT License)을 기반한 **AI 에이전트 스킬 엔지니어링 완전 교육 과정**입니다.

---

## 📚 자료 구조

### 1. **SYLLABUS.md** — 커리큘럼 전체 명세
6회차 과정의 학습 목표, 회차별 주제, 핸즈온 실습을 일목요연하게 정리한 마스터 플랜입니다.
- 정규 과정 4회차: 단일 스킬 엔지니어링 기초
- 심화 과정 2회차: 엔터프라이즈 스킬 플릿 & 런타임

### 2. **ARCHITECTURE-MAP.md** — 시스템 아키텍처 시각화
4계층 스킬 플릿, PreToolUse Hook 시퀀스, 듀얼 브라우징 엔진 등을 Mermaid 다이어그램으로 해부합니다.

### 3. **excerpts/** — 13강의 심층 교재

| 강 | 제목 | 핵심 패턴 | 원본 출처 |
|---|---|---|---|
| **01강** | 스킬의 해부 구조 & 라우팅 | The Minimalist Pattern | `unfreeze/SKILL.md` |
| **02강** | Hook과 절대 보안 방어 | The Gatekeeper Pattern | `careful/bin/` |
| **03강** | 워크플로 & Iron Law | The State Machine Pattern | `investigate/SKILL.md` |
| **04강** | 템플릿 컴파일 파이프라인 | Multi-Target Compiler Pattern | `scripts/gen-skill-docs.ts` |
| **05강** | 점진적 로딩 & 가상 컨텍스트 | Virtual Memory Pattern | `autoplan/SKILL.md` |
| **06강** | 결정적 워커 & Fixture 테스트 | Deterministic Worker Pattern | `browser-skills/` |
| **07강** | 스킬 테스트 엔지니어링 | The Quality Gate Pattern | `scripts/validate.sh` |
| **08강** (심화) | 62개 스킬의 관제탑 | The Traffic Controller Pattern | `gstack-router/SKILL.md` |
| **09강** (심화) | 동적 모델 오버레이 | Dynamic Adaptation Pattern | `model-overlays/fable-5.md` |
| **10강** (심화) | 프로덕션 런타임 프로토콜 | Fault-Tolerant Runtime Pattern | `browse/src/server.ts` |
| **11강** (심화) | 컨텍스트 2층 예산제도 | Two-Tier Budgeting Pattern | `scripts/validate.sh` |
| **12강** (심화) | 스킬을 생성하는 메타 스킬 | Meta-Programming Pattern | `skillify/SKILL.md` |
| **13강** (심화) | 세션 간 결정 메모리 | Blackboard Memory Pattern | `CLAUDE.md` |

### 4. **workbook/** — 핸즈온 실습 환경

#### 실습 랩
- **lab01-routing**: 한국어 커밋 제안 스킬 제작
- **lab02-hook**: 비밀 키 수정 차단 훅
- **lab03-workflow**: 코드베이스 모듈 분석 워크플로
- **lab04-skill-compiler**: 마크다운 컴파일러 & 정적 린터
- **lab05-meta-router**: 다중 스킬 라우팅 메타 라우터
- **lab06-decision-memory**: 세션 불변 의사결정 로그

#### 검증 도구
- **check-env.bat / check-env.sh**: 환경 사전 점검 (Node, Bun, Python)
- **verify_all.bat**: 모든 랩의 자동 테스트 실행
- **test_lab*.sh**: 각 랩별 개별 테스트 스크립트

#### 추가 자료
- **solutions/**: 각 랩의 완전한 해답 코드
- **self-check.md**: 자체 평가 체크리스트

---

## 🎯 학습 진행 방식

### 정규 과정 (Week 1-4)
1. **SYLLABUS.md**에서 이번 주 학습 목표 확인
2. **excerpts/** 에서 해당 강의 교재 읽기 (20-30분)
3. **workbook/** 에서 핸즈온 실습 수행 (60-90분)
4. **solutions/** 와 자신의 코드 비교
5. **self-check.md**로 자체 평가

### 심화 과정 (Week 5-6)
- 정규 과정 이후, 엔터프라이즈 규모 패턴 심화 학습
- ARCHITECTURE-MAP.md로 시스템 전체 구조 파악
- 08강~13강 교재로 고급 엔지니어링 철학 체득

---

## 🛠️ 환경 설정

### 필수 사전 조건
```bash
# Windows (Git Bash / PowerShell)
./workbook/check-env.bat

# macOS / Linux
bash ./workbook/check-env.sh
```

### 스킬 임시 설치 & 테스트
```bash
# 단일 랩 테스트
bash ./workbook/labs/lab01-routing/test.sh

# 전체 검증
./workbook/verify_all.bat  # Windows
bash ./workbook/verify_all.sh  # macOS/Linux
```

---

## 📖 추천 읽기 순서

### 첫 번째 읽음 (아키텍처 이해)
1. **SYLLABUS.md** — 전체 커리큘럼 개요 (10분)
2. **ARCHITECTURE-MAP.md** — 4계층 시스템 아키텍처 (15분)
3. **excerpts/01-anatomy.md** — 최소주의 패턴 기초 (20분)

### 강의별 깊이 학습
각 주차마다:
- 해당 **excerpts/NN-*.md** 정독 (25-30분)
- **workbook/labs/labNN-*/** 실습 (60-90분)
- **solutions/** 모범답 검토 (10-15분)

### 심화 강의 (Week 5-6)
- ARCHITECTURE-MAP.md 재검토
- excerpts/08-13강 집중 학습
- 라우터, 훅 컴포지션, 메타 패턴 실습

---

## 🔍 각 강의의 핵심 질문

| 강 | 배워야 할 핵심 질문 |
|---|---|
| 01강 | "모델은 스킬 이름과 설명 중 뭘 먼저 본다?" |
| 02강 | "Hook이 프롬프트와 다른 이유는?" |
| 03강 | "무한 루프를 막는 3-Strike 중단은 뭔가?" |
| 04강 | "왜 마크다운을 코드로 생성할까?" |
| 05강 | "1,500줄을 200줄로 줄이는 방법은?" |
| 06강 | "테스트 코드를 자동으로 생성할 수 있나?" |
| 07강 | "무료 정적 린터로 95% 까지 확인하려면?" |
| **08강** | "**62개 스킬을 어떻게 관제할까?**" |
| **09강** | "**모델마다 결함을 동적으로 보정하려면?**" |
| **10강** | "**Degraded 모드는 왜 필요할까?**" |
| **11강** | "**컨텍스트 예산을 2층으로 나누는 이유는?**" |
| **12강** | "**일회성 작업을 영구 스킬로 만들 수 있나?**" |
| **13강** | "**세션의 기억 상실을 치료하는 방법은?**" |

---

## 📋 이 교육 자료의 기준

- **원본 소스**: Garry Tan의 `gstack` v1.91.1 (Commit `2a113ae7`), MIT License
- **철학**: 프롬프트 마법을 걷어내고, **결정적 소프트웨어 엔지니어링**으로 에이전트를 통제한다
- **대상**: 스킬을 **직접 만드는** 개발자 / AI 엔지니어
- **학습 시간**: 정규 과정 20-25시간, 심화 과정 10-15시간

---

## ✨ 특징

- ✅ 실제 gstack 소스코드 발췌 & 해석 (마법이 아닌 실제 구현)
- ✅ 6개의 완전한 핸즈온 랩 + 검증 테스트
- ✅ 아키텍처 시각화 (Mermaid 다이어그램)
- ✅ 강의별 핵심 패턴명 명시 (무명 개념 해결)
- ✅ 심화 과정으로 엔터프라이즈 규모 기술까지 확장
- ✅ 모든 강의와 랩에 명확한 성공 기준

---

**Happy Learning! 🚀**
