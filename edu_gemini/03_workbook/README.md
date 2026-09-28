# gstack 스킬 실전 아키텍처 워크북 (Workbook)

이 워크북은 AI 코딩 에이전트의 스킬을 직접 설계, 코딩, 테스트하는 6단계 핸즈온 실습 가이드입니다.

---

## 🛠️ 실습 랩 로드맵 (정규 4종 + 심화 2종)

| 회차 | 랩 디렉토리 | 대상 스킬 | 만드는 것 | 핵심 학습 개념 | 대응 교재 |
|---|---|---|---|---|---|
| **정규 1회차** | **[lab01-routing](lab01-routing/)** | `commit-msg-ko` | 한국어 커밋 제안기 | Frontmatter, 자연어 라우팅, allowed-tools | `01-anatomy.md` |
| **정규 2회차** | **[lab02-hook](lab02-hook/)** | `protect-secrets` | 기밀 파일 차단 Hook | PreToolUse 훅, JSON 안전 파싱, fail-closed | `02-hooks-and-safety.md` |
| **정규 3회차** | **[lab03-workflow](lab03-workflow/)**| `module-analyst` | 3단계 모듈 분석기 | Iron Law, 게이트웨이 상태머신, 3-Strike 중단 | `03-workflow-iron-law.md` |
| **정규 4회차** | **[lab04-compiler](lab04-compiler/)**| `skill-compiler` | 템플릿 컴파일러 | `gen.sh` 치환 엔진, 점진적 로딩, `validate.sh` | `04-templates`, `05-progressive` |
| **심화 5회차** | **[lab05-router](lab05-router/)** 🌟 | `meta-router` | 관제탑 라우터 | 다중 스킬 의도 분석, 키워드 충돌 방지 매트릭스 | `08-grand-router.md` |
| **심화 6회차** | **[lab06-memory](lab06-memory/)** 🌟 | `decision-memory`| 세션 불변 결정 메모리 | 세션 무상태성 치료, `decisions.jsonl` 로그 | `13-decision-memory.md` |

---

## 🚀 실습 실행 가이드 (Windows & Bash 완벽 지원)

모든 랩은 **Windows 네이티브 환경(`cmd.exe`, 파일 탐색기 더블클릭)**과 **Git Bash / Linux / macOS 환경**을 100% 동시 지원합니다.

| 회차 / 랩 | Windows 명령 프롬프트 / 탐색기 | Git Bash / Linux / macOS |
|---|---|---|
| **0. 환경 점검** | `check-env.bat` (더블클릭 가능) | `bash check-env.sh` |
| **Lab 01 (라우팅)** | `cd lab01-routing && test_lab01.bat` | `cd lab01-routing && bash test_lab01.sh` |
| **Lab 02 (보안 훅)** | `cd lab02-hook && test-hook.bat` | `cd lab02-hook && bash test-hook.sh` |
| **Lab 03 (워크플로)** | `cd lab03-workflow && test_lab03.bat` | `cd lab03-workflow && bash test_lab03.sh` |
| **Lab 04 (컴파일러)** | `cd lab04-compiler && test_lab04.bat` | `cd lab04-compiler && bash test_lab04.sh` |
| **Lab 05 (관제 라우터)** 🌟 | `cd lab05-router && test_lab05.bat` | `cd lab05-router && bash test_lab05.sh` |
| **Lab 06 (결정 메모리)** 🌟 | `cd lab06-memory && test_lab06.bat` | `cd lab06-memory && bash test_lab06.sh` |
| **종합 6개 랩 검증** | `verify_all.bat` (더블클릭 가능) | `bash ../05_instructor/verify_all.sh` |

막힐 때는 `solutions/`의 모범 답안을 참고하세요.
모든 솔루션은 `verify_all.bat` 및 `verify_all.sh`를 통해 Windows와 POSIX 쉘 양쪽에서 100% 검증을 통과했습니다.

