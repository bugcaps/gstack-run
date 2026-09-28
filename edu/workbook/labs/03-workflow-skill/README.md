# Lab 03 — 워크플로 스킬 설계 (investigate 패턴)

## 목표
- 여러 단계로 된 스킬이 **건너뛰기·추측·무한 반복**을 막는 장치를 원본에서 뽑아낸다.
- 그 장치를 본떠 `explain-module`(또는 `pr-describe`) 스킬을 설계하고 작성한다.

## 배경
- 발췌본: [04-workflow-skill](../../../excerpts/04-workflow-skill/)
- 원본: `gstack/investigate/SKILL.md.tmpl` (268줄. 생성된 `SKILL.md`는 704줄이니 **.tmpl을 읽을 것**)

investigate의 장치 (원본에서 확인):

| 장치 | 원본 위치 | 효과 |
|---|---|---|
| Iron Law: *NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST* | `## Iron Law` | 최우선 규칙 하나를 맨 위에 둔다 |
| Phase 1~5 + 단계별 출력물 (`"Root cause hypothesis: ..."`) | `## Phase 1` ~ `## Phase 5` | 출력물이 없으면 단계를 건너뛴 것이 드러난다 |
| 3-strike rule: 가설 3개가 실패하면 **STOP** → AskUserQuestion A/B/C | Phase 3 | 무한 반복 방지 |
| 수정 파일이 5개 넘으면 AskUserQuestion으로 영향 범위 확인 | Phase 4 | 범위 폭주 방지 |
| Scope Lock: freeze 상태 파일에 디렉터리를 기록 | `## Scope Lock` | hook으로 편집 범위를 강제 (Lab 02와 연결) |
| 질문은 "ONE question at a time" | Phase 1 | 사용자 피로 감소 |
| Red flags 목록 | Phase 3 끝 | 모델의 자기 점검 |
| 고정 보고 블록 + `DONE / DONE_WITH_CONCERNS / BLOCKED` | Phase 5 | 결과를 기계적으로 확인 가능 |

## 단계
1. `investigate/SKILL.md.tmpl`을 읽고 [worksheet.md](worksheet.md) **A 표**를 채운다 (15분).
2. 만들 스킬을 고른다.
   - `explain-module`: 모듈을 file:line 근거와 함께 설명 (읽기 전용)
   - `pr-describe`: 브랜치 diff로 PR 설명 작성 (읽기 전용 + `gh`?)
3. 워크시트 **B**를 채운다. 특히 `allowed-tools`는 **도구마다 사용 이유를 한 줄씩** 쓴다.
4. `~/.claude/skills/<name>/SKILL.md`로 작성하고 **C 셀프 리뷰**를 한다.
5. 실제 저장소에서 두 번 실행한다: (a) 작은 디렉터리, (b) 일부러 큰 디렉터리 → 중단 조건이 발동하는지 확인한다.

## 성공 기준
- [ ] Iron Law가 한 문장이고 검증 가능하다
- [ ] 모든 단계에 이름 붙은 출력물이 있다
- [ ] 숫자로 된 중단 조건이 2개 이상 있고, (b) 실행에서 실제로 발동했다
- [ ] AskUserQuestion이 A/B/C 선택지 형식이다
- [ ] 최종 보고가 고정 블록 + Status 3값이다
- [ ] 읽기 전용 스킬인데 `Write`/`Edit`가 `allowed-tools`에 없다

## 막히면
- 단계 나누기가 어렵다면 "사람 시니어라면 어떤 순서로 보고, 각 순서가 끝났다는 걸 어떻게 알까?"를 먼저 적어 보세요.
- 모델이 단계를 건너뛴다면 해당 단계의 **출력물 문장**을 강제하세요 (예: `출력물: "범위: …"`).
- 참고 답안: [`solutions/03-workflow-skill/explain-module/SKILL.md`](../../solutions/03-workflow-skill/explain-module/SKILL.md)

<details><summary>워크시트 A 정답</summary>

| 요소 | investigate |
|---|---|
| Iron Law | NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST |
| 단계 | 1 Root Cause Investigation · 2 Pattern Analysis · 3 Hypothesis Testing · 4 Implementation · 5 Verification & Report |
| 출력물 | Phase 1 → "Root cause hypothesis: …", Phase 5 → DEBUG REPORT 블록 |
| 중단 조건 | 가설 3개 실패 → STOP / 수정 시도 3회 이상 실패 → 아키텍처를 의심 |
| AskUserQuestion | 정보 부족(한 번에 하나), 3-strike, 수정 파일 5개 초과 |
| 범위 제한 | Scope Lock (freeze-dir.txt + freeze hook) |
| 완료 상태 | DONE / DONE_WITH_CONCERNS / BLOCKED |
| Red flags | "Quick fix for now", 데이터 흐름 추적 전 수정 제안, 수정할 때마다 새 문제 발생 |
</details>
