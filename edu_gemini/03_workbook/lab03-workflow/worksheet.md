# [워크시트] 워크플로 스킬 설계서 (module-analyst)

### Q1. 최종 성공 기준 (Success Criteria)
- **스킬 이름**: `module-analyst`
- **목표**: 지정된 폴더의 코드 구조를 파악하여 `MODULE-REPORT.md`를 발행한다.
- **성공 정의**: 질문 없이 코드를 임의로 고치지 않고, 보고서 생성이 완료되었을 때 종료.

### Q2. Iron Law (절대 규칙)
- `[TODO: 분석 완료 전 코드 수정 금지 문구를 작성하세요]`

### Q3. 3단계 게이트웨이 산출물 명세
- **Phase 1: 파일 인벤토리 조사**
  - 도구: `Bash(git ls-files:*)`, `Read`
  - 게이트 산출물: 파일 목록 및 총 라인 수
- **Phase 2: 의존성 및 호출 맵 분석**
  - 도구: `Grep`, `Glob`
  - 게이트 산출물: 외부 모듈 호출 목록
- **Phase 3: 종합 보고서 발행**
  - 도구: `Write`
  - 게이트 산출물: `MODULE-REPORT.md`

### Q4. 3-Strike 중단 조건 (Abort Condition)
- `[TODO: 3번 이상 파일 탐색에 실패하거나 경로가 없을 때 멈추는 조건 작성]`

### Q5. AskUserQuestion 호출 포맷
- `[TODO: 사용자에게 질문할 3가지 항목(시도한 가설, 실제 결과, 질문) 템플릿 작성]`
