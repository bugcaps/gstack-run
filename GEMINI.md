# GEMINI.md

## 🧠 1. 코딩 전 생각하기

**가정하지 마세요. 혼란스러움을 숨기지 마세요. 절충안을 표면화하세요.**

구현하기 전에:
* 가정을 명확하게 명시하세요. 불확실하다면 질문하세요.
* 여러 해석이 존재한다면 이를 제시하고, 조용히 임의로 선택하지 마세요.
* 더 간단한 접근 방식이 있다면 말하세요. 타당한 이유가 있다면 거절(Push back)하세요.
* 불명확한 부분이 있다면 멈추세요. 무엇이 혼란스러운지 명시하고 질문하세요.

## 🪄 2. 단순성 우선

**문제를 해결하는 최소한의 코드만 작성하세요. 추측성 코드는 작성하지 마세요.**
* 요청받은 것 이상의 기능은 추가하지 마세요.
* 일회용 코드를 위한 추상화는 하지 마세요.
* 요청되지 않은 "유연성"이나 "구성 가능성(configurability)"은 추가하지 마세요.
* 불가능한 시나리오에 대한 예외 처리는 하지 마세요.
* 50줄로 끝낼 수 있는 코드를 200줄로 작성했다면 다시 작성하세요.

## ✂️ 3. 외과 수술 같은 정밀한 변경

**반드시 필요한 부분만 건드리세요. 자신이 만든 문제만 정리하세요.**
기존 코드를 수정할 때:
* 인접한 코드, 주석 또는 포맷팅을 굳이 "개선"하지 마세요.
* 망가지지 않은 것을 리팩토링하지 마세요.
* 본인의 방식과 다르더라도 기존 스타일을 따르세요.
* 무관한 데드 코드를 발견하면 언급만 하고 삭제하지 마세요.

## 🎯 4. 목표 지향적 실행

**성공 기준을 정의하세요. 검증될 때까지 반복하세요.**
작업을 검증 가능한 목표로 변환하세요:
* "유효성 검사 추가" → "잘못된 입력에 대한 테스트를 작성한 후 통과시키기"
* "버그 수정" → "버그를 재현하는 테스트를 작성한 후 통과시키기"
* "X 리팩토링" → "리팩토링 전후로 테스트가 통과하는지 확인하기"

---

## 🛡️ 5. 품질 방지 프로토콜 & 자가 비판 (Quality & Self-Critique Gate)

**형식적 완료에 안도하지 마세요. 얄팍한 요약과 공장형 복붙을 경계하세요.**

* **형식적 완료(Syntactic Completion)의 함정 경계**:
  * "파일이 에러 없이 생성되었다", "스크립트가 exit 0으로 끝났다"고 해서 작업이 완료된 것이 아닙니다.
  * 실제 사용자가 체감하는 **지식 밀도(Semantic Density)**와 **시각적 완성도(Visual Polish)**가 진짜 성공 기준입니다.
* **벤치마크 정량 메트릭 측정 의무화**:
  * 기존 산출물이나 벤치마크를 개선/대체할 때는, 먼저 기존 산출물의 분량(바이트 수, 라인 수), 구조적 다양성(표, 코드 블록, 비교 레이아웃 등)을 숫자로 측정하고, 그 기준 이상의 밀도를 명시적 스펙으로 삼으세요.
* **게으른 요약(Lazy Abstraction) 금지**:
  * 구체적인 기술적 디테일(원본 소스코드 경로, 행 번호, 실패했던 버그 히스토리 등)을 뭉뚱그려 일반론적인 요약문으로 축약하지 마세요. 실전성은 디테일에서 나옵니다.
* **보고 전 자가 비판(Self-Critique Gate)**:
  * 사용자에게 결과물을 보고하기 전에 스스로 자문하세요:
    1. *"기존 원본과 나란히 비교했을 때 분량이나 깊이에서 밀리지 않는가?"*
    2. *"슬라이드나 문서가 단조로운 템플릿 복붙이 아니라, 내용에 맞는 시각적 변주가 적용되었는가?"*
    3. *"시니어 엔지니어 입장에서 실질적으로 배울 점이 있는 깊이인가?"*
  * 답이 'No'라면 사용자에게 보고하기 전에 스스로 다시 작성하세요.

---

## 🛠️ gstack

모든 웹 브라우징 작업에는 **gstack의 `/browse` 스킬**을 사용하고, `mcp__claude-in-chrome__*` 도구는 절대 사용하지 마세요.

### 📜 핵심 원칙 (Ethos & Reuse Ladder)
* **Boil the Ocean**: 테스트, 엣지 케이스, 에러 처리 경로를 완전하게 작성합니다.
* **Search Before Building**: 무엇을 만들지 결정하기 전에 이미 있는 헬퍼/유틸을 먼저 검색하고 재사용합니다.
* **The Reuse Ladder**:
  1. 저장소의 기존 헬퍼 / 함수 / 패턴
  2. 표준 라이브러리
  3. 플랫폼 네이티브 기능 (CSS > JS, DB 제약조건 > 앱 코드)
  4. 이미 설치된 의존성 패키지
* **User Sovereignty**: AI 모델은 제안하고 최종 결정은 사용자가 내립니다.
* **Voice**: 직접적이고 구체적인 개발자 톤앤매너. 파일, 함수, 명령어, 사용자 영향 명시.

### 🧰 사용 가능한 gstack 스킬 목록
| 스킬 | 역할 | 설명 |
|------|------|------|
| `/office-hours` | **YC Office Hours** | 6가지 질문을 통해 제품 방향성 검증 및 재정의 |
| `/plan-ceo-review` | **CEO / Founder** | 제품 전략적 도전 및 스코프 최적화 (확장/유지/축소) |
| `/plan-eng-review` | **Eng Manager** | 아키텍처, 데이터 흐름, 다이어그램, 엣지 케이스, 테스트 계획 잠금 |
| `/plan-design-review`| **Senior Designer** | 디자인 차원별 평가(0-10) 및 AI 슬롭(Slop) 방지 |
| `/plan-devex-review` | **DevEx Lead** | 개발자 경험(DX) 인터랙티브 평가 및 마찰 요소 제거 |
| `/design-consultation`| **Design Partner** | DESIGN.md 생성 및 풀 디자인 시스템 구축 |
| `/design-shotgun` | **Design Explorer** | 4~6개 시각 목업 비교 보드 생성 및 취향 피드백 학습 |
| `/design-html` | **Design Engineer** | 목업을 프로덕션급 동적 HTML/CSS(Pretext)로 변환 |
| `/review` | **Staff Engineer** | CI 통과 후 프로덕션에서 터질 버그 선제 검출 및 자동 수정 |
| `/deslop-shared-libs`| **Shared Code Review** | 최근 작업에서 공유 코드 추출 기회 분석 |
| `/investigate` | **Debugger** | 체계적 근본 원인 분석 (조사 없는 수정 금지) |
| `/design-review` | **Designer Who Codes** | UI 디자인 감사 및 자동 커밋 수정 |
| `/devex-review` | **DX Tester** | 온보딩, 문서, TTHW 실제 테스트 및 실시간 평가 |
| `/qa` | **QA Lead** | 실제 브라우저 구동 테스트, 버그 수정, 회귀 테스트 생성 |
| `/qa-only` | **QA Reporter** | 코드 수정 없이 순수 버그 리포트만 발행 |
| `/pair-agent` | **Multi-Agent** | 다른 에이전트(Codex, OpenClaw 등)와 공유 브라우저 협업 |
| `/cso` | **Chief Security Officer** | OWASP + STRIDE 보안 감사 및 분석 |
| `/ship` | **Release Engineer** | main 동기화, 테스트 검증, 커버리지 확인 후 PR 생성 |
| `/land-and-deploy` | **Release Engineer** | PR 머지, 배포 대기 및 프로덕션 헬스 검증 |
| `/canary` | **SRE** | 배포 후 콘솔 에러, 성능 회귀 모니터링 |
| `/benchmark` | **Performance Engineer** | 로딩 시간, Core Web Vitals 벤치마크 비교 |
| `/document-release` | **Tech Writer** | 배포된 코드 diff에 맞추어 README, ARCHITECTURE 등 자동 동기화 |
| `/document-generate`| **Doc Author** | Diataxis 프레임워크 기반 신규 문서 생성 |
| `/retro` | **Eng Manager** | 주간 엔지니어링 회고 리포트 |
| `/browse` | **QA Engineer** | 브라우저 조작 및 스크린샷 (Aside 우선 / gstack Chromium 폴백) |
| `/scrape` | **Data Extractor** | 웹 페이지 구조화 데이터 추출 |
| `/setup-browser-cookies`| **Session Manager**| 기존 브라우저 쿠키를 gstack 브라우저로 복사 |
| `/autoplan` | **Review Pipeline** | CEO → Design → DX → Eng 검토를 일괄 자동 수행 |
| `/spec` | **Spec Author** | 요구사항을 5단계 실행 가능한 정밀 스펙으로 구체화 |
| `/learn` | **Memory** | 세션 간 프로젝트 패턴, 주의점, 선호도 메모리 관리 |
| `/make-pdf` | **Publisher** | 마크다운 문서를 다이어그램 포함 출판 품질 PDF로 변환 |
| `/diagram` | **Diagram Maker** | 자연어를 편집 가능한 Excalidraw / Mermaid 다이어그램으로 생성 |
| `/codex` | **Second Opinion** | OpenAI Codex CLI를 통한 독립적 코드 리뷰 및 크로스 체크 |
| `/careful` | **Safety Guardrail**| 위험 명령어(rm -rf, DROP TABLE, force-push 등) 사전 경고 |
| `/freeze` | **Edit Lock** | 작업 디렉토리 범위를 잠가 범위 밖 수정 방지 |
| `/guard` | **Full Safety** | `/careful` + `/freeze` 동시 활성화 |
| `/unfreeze` | **Unlock** | 수정 잠금 해제 |
| `/open-gstack-browser` | **Browser UI** | 헤드(GUI) 모드로 사이드바 탑재 gstack 브라우저 실행 |
| `/setup-deploy` | **Deploy Config** | `/land-and-deploy`용 배포 환경 원클릭 설정 |
| `/setup-gbrain` | **GBrain Setup** | GBrain 온보딩 및 MCP 연동 |
| `/sync-gbrain` | **GBrain Sync** | 저장소 코드를 GBrain에 재인덱싱 |
| `/gstack-upgrade` | **Self Updater** | gstack 최신 버전으로 자가 업데이트 |