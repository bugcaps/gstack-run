# gstack 스킬 아키텍처 실전 해부 교재 (Textbook Index)

- **교재 원본**: Garry Tan의 `gstack` v1.91.1 (Commit `2a113ae7`), MIT License
- **교재 철학**: "프롬프트 마법을 걷어내고, 유닉스 철학 기반의 결정적 소프트웨어 엔지니어링으로 에이전트를 통제한다."
- **교재 구성**: 정규 과정 7강 + 심화 과정 6강 (총 13강의 심층 소스코드 해부)

---

## 📚 교재 전체 목차 및 회차 매핑

### Part 1: 정규 과정 (단일 스킬 엔지니어링)
| 강의 | 제목 | gstack 원본 소스코드 | 핵심 엔지니어링 패턴 |
|---|---|---|---|
| **[01강](01-anatomy.md)** | **스킬의 해부 구조 & 라우팅** | `unfreeze/SKILL.md` (48줄 전문)<br>`ETHOS.md` (Boil the Ocean) | The Minimalist Pattern<br>자연어 라우팅 엔진, 최소 권한 |
| **[02강](02-hooks-and-safety.md)** | **Hook과 절대 보안 방어** | `careful/bin/check-careful.sh` (314줄)<br>`careful/bin/hook-extract.sh` | The Gatekeeper Pattern<br>grep 따옴표 버그 해부, fail-closed 백스톱 |
| **[03강](03-workflow-iron-law.md)**| **워크플로 & Iron Law** | `investigate/SKILL.md` (704줄)<br>`ETHOS.md` (User Sovereignty) | The State Machine Pattern<br>5단계 게이트웨이, 3-Strike 중단 탈출 |
| **[04강](04-templates-codegen.md)**| **템플릿 컴파일 파이프라인** | `scripts/gen-skill-docs.ts`<br>`hosts/` 디렉토리 | Multi-Target Compiler Pattern<br>마크다운 드리프트 방지, 크로스 호스트 |
| **[05강](05-progressive-loading.md)**| **점진적 로딩 & 가상 컨텍스트** | `autoplan/SKILL.md`<br>`autoplan/sections/` | Virtual Memory Pattern<br>Attention Sink 방어, 토큰 80% 절약 |
| **[06강](06-deterministic-worker.md)**| **결정적 워커 & Fixture 테스트**| `browser-skills/hackernews/`<br>`browser-skills/common/` | Deterministic Worker Pattern<br>환각 작업 코드 오프로딩, 무료 유닛테스트 |
| **[07강](07-testing-strategy.md)** | **스킬 테스트 엔지니어링** | `scripts/validate.sh`<br>`test/helpers/hermetic-env.ts`| The Quality Gate Pattern<br>무료 95% 정적 린터 vs 유료 5% LLM eval |

---

### Part 2: 심화 과정 (엔터프라이즈 스킬 플릿 & 런타임) 🌟
| 강의 | 제목 | gstack 원본 소스코드 | 핵심 엔지니어링 패턴 |
|---|---|---|---|
| **[08강](08-grand-router.md)** | **62개 스킬의 관제탑** | `gstack-router/SKILL.md`<br>`router/rules.ts` | The Traffic Controller Pattern<br>"오탐이 미탐보다 싸다", 트래픽 분기 |
| **[09강](09-model-overlays.md)** | **동적 모델 오버레이** | `model-overlays/fable-5.md`<br>`scripts/resolvers/` | Dynamic Adaptation Pattern<br>모델별 결함 보정, `{{INHERIT}}` 상속 래퍼 |
| **[10강](10-runtime-protocol.md)** | **프로덕션 런타임 프로토콜** | `browse/src/server.ts`<br>`ARCHITECTURE.md` (Daemon) | Fault-Tolerant Runtime Pattern<br>STATUS 시그널, 장애 시 Degraded 모드 |
| **[11강](11-context-budget.md)** | **컨텍스트 2층 예산제도** | `scripts/validate.sh` (budget)<br>`test/catalog-budget.test.ts`| Two-Tier Budgeting Pattern<br>카탈로그 하드 예산 vs 본문 소프트 예산 |
| **[12강](12-meta-skillify.md)** | **스킬을 생성하는 메타 스킬** | `skillify/SKILL.md` (120줄 전문)<br>`skillify/src/generator.ts` | Meta-Programming Pattern<br>세션 실행 궤적의 영구 스킬 자동 동결 |
| **[13강](13-decision-memory.md)**| **세션 간 결정 메모리** | `CLAUDE.md` (Decision Memory)<br>`gstack-decision-log/` | Blackboard Memory Pattern<br>세션 무상태성 치료, `decisions.jsonl` |
