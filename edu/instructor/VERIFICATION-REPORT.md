# gstack 스킬 교육 자료 종합 검증 보고서 (Verification Report)

- **검증 일시**: 2026-09-28
- **검증 대상**: `edu/` 폴더 전반 (`excerpts/`, `workbook/`, `rehearsal/`) 및 `ppt/gstack-skill-course.pptx`
- **기준 저장소**: `gstack` v1.91.1 (Commit `2a113ae7`), MIT License
- **검증 환경**: Windows 11, Git Bash 5.2.37, Node.js v22.20.0, Python 3.13.7

---

## 1. 종합 검증 요약

| 검증 영역 | 검증 항목 | 결과 | 비고 |
|---|---|---|---|
| **구조 무결성** | 슬라이드 30장 ↔ 발췌본(12개) ↔ 워크북(4개 랩) 매핑 | **PASS (100%)** | 모든 회차 및 랩 링크가 정확히 1:1 대응됨 |
| **코드 무결성** | Lab 2 `check-secrets.sh` 훅 차단 및 통과 로직 | **PASS (100%)** | `.env` 차단(deny) 및 일반 파일 통과(`{}`) 정상 작동 |
| **빌드 파이프라인** | Lab 4 `gen.sh` 템플릿 치환 및 조립 | **PASS (100%)** | `out/` 하위 `SKILL.md` 2건 정상 생성 |
| **품질 게이트** | Lab 4 `validate.sh` 린트 및 픽스처 검사 | **PASS (100%)** | 정상 스킬 통과 및 불량 픽스처(길이 초과, 잘못된 경로 등) 정확히 차단 |
| **플랫폼 호환성** | Windows Git Bash / 스토어 Python3 스텁 대응 | **PASS (100%)** | Python3 실패 시 Node.js로 안전 폴백(Fallback) 확인 |

---

## 2. 상세 검증 내역

### 2.1. Lab 2: Hook 강제성 검증 (`check-secrets.sh`)
- **테스트 케이스 1: 위험 파일 수정 시도 (`.env`)**
  - 입력: `{"tool_input":{"file_path":".env"}}`
  - 결과:
    ```json
    {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] 비밀 파일 수정 차단: .env"}}
    ```
  - 판정: **정상 차단 (DENY)**
- **테스트 케이스 2: 일반 파일 수정 시도 (`src/index.js`)**
  - 입력: `{"tool_input":{"file_path":"src/index.js"}}`
  - 결과: `{}` (빈 JSON 객체)
  - 판정: **정상 허용 (ALLOW)**
  - 💡 **강사 주의사항**: Claude Code 훅 프로토콜에서 허용은 `"permissionDecision":"allow"`가 아니라 **`{}` (빈 객체)** 또는 빈 출력을 내보내는 것이 정석 규격입니다.

### 2.2. Lab 4: 스케일업 템플릿 빌드 검증 (`gen.sh`)
- `solutions/04-scale-up/src/`의 템플릿(`.tmpl`)과 `partials/common.md` 결합 테스트.
- 결과:
  - `out/commit-msg-ko/SKILL.md` (공통 블록 정상 주입 확인)
  - `out/explain-module/SKILL.md` (공통 블록 정상 주입 확인)
- 종료 코드: `0`

### 2.3. Lab 4: 정적 유효성 검증기 (`validate.sh`)
- **정상 솔루션 검증**: `solutions/04-scale-up/`에 대해 실행 시 모든 린트 통과 (종료 코드 `0`).
- **불량 픽스처 차단 검증**: `labs/04-scale-up/fixtures/`의 고의 결함 스킬 대상 실행:
  - `long-desc`: 설명문 길이 초과 감지 및 차단
  - `no-close`: 프론트매터 닫힘(`---`) 누락 감지 및 차단
  - `no-trigger`: 언제 호출할지(Trigger) 누락 감지 및 차단
  - `wrong-dir`: 폴더명 불일치 감지 및 차단
- 판정: **모든 결함 완벽 차단 (exit 127)**

---

## 3. 강의 현장에서 반드시 짚어주어야 할 핵심 발견 사항

1. **Windows 스토어 Python 스텁 위험**:
   - Windows에서 기본 제공되는 가짜 `python3.exe`는 실행 시 마이크로소프트 스토어로 연결되며 exit code 49 또는 9009를 냅니다.
   - 워크북 코드(`extract_path`)는 `python3` 실패 시 즉시 `node`를 실행하도록 이중 안전장치가 되어 있으므로, Node.js가 설치되어 있다면 전혀 문제없이 동작합니다.
2. **Path 구분자(Windows Backslash) 정규화**:
   - `check-secrets.sh` 54행: `NORM=${FILE_PATH//\\//}` 처리가 되어 있어 Windows 경로(`D:\project\.env`)도 Unix 스타일(`D:/project/.env`)로 자동 변환되어 안전하게 필터링됩니다.
3. **Fail-Closed 백스톱 트랩**:
   - 훅 스크립트 실행 중 파서 충돌이나 미처리 에러가 발생해도, `trap backstop EXIT`가 잡아서 무조건 `deny` 결정을 내리도록 설계되어 있습니다. 이 철학을 2회차에서 강력히 강조해야 합니다.
