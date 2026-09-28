# 04. 워크플로 스킬 설계: `/investigate`

**원본:** `gstack/investigate/SKILL.md.tmpl` (268줄 중 1–28, 64–98, 178–268행 발췌), 비교용 `gstack/investigate/SKILL.md` (704줄)

## 이 발췌에서 배울 것
1. 좋은 워크플로 스킬 = **불변 규칙(Iron Law) + 순서 있는 Phase + 멈춤 조건 + 정형 출력**.
2. 모델이 "그럴듯하게 대충" 끝내지 못하도록 **증거 요구와 중단 규칙**을 명문화한다.
3. 사용자 판단이 필요한 지점을 **AskUserQuestion 선택지**로 미리 설계한다.

## ① frontmatter: 선제 호출을 명시 (1–28행)

```yaml
---
name: investigate
preamble-tier: 2
# 📝 공통 preamble 중 어느 단계까지 포함할지 (05-template-system 참고)
version: 1.0.0
description: |
  Systematic debugging with root cause investigation. Four phases: investigate,
  analyze, hypothesize, implement. Iron Law: no fixes without root cause.
  Use when asked to "debug this", "fix this bug", "why is this broken",
  "investigate this error", or "root cause analysis".
  Proactively invoke this skill (do NOT debug directly) when the user reports
  errors, 500 errors, stack traces, unexpected behavior, "it was working
  yesterday", or is troubleshooting why something stopped working. (gstack)
# 📝 "Proactively invoke … (do NOT debug directly)" — 사용자가 스킬 이름을 몰라도
# 📝    증상만 말하면 이 스킬로 라우팅되도록 하는 문장
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
triggers:
  - debug this
  - fix this bug
  - why is this broken
  - root cause analysis
  - investigate this error
# ... (생략: freeze hook — 03-composition 참고, 29–39행 / gbrain 컨텍스트 쿼리 — 40–61행) ...
---
```

## ② 불변 규칙과 Phase 1 (64–98행)

~~~~markdown
{{PREAMBLE}}
<!-- 📝 생성 시 약 350줄의 공통 블록으로 치환됨 -->

# Systematic Debugging

## Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Fixing symptoms creates whack-a-mole debugging. Every fix that doesn't address root cause makes the next bug harder to find. Find the root cause, then fix it.

---

{{GBRAIN_CONTEXT_LOAD}}

## Phase 1: Root Cause Investigation

Gather context before forming any hypothesis.

1. **Collect symptoms:** Read the error messages, stack traces, and reproduction steps. If the user hasn't provided enough context, ask ONE question at a time via AskUserQuestion.

2. **Read the code:** Trace the code path from the symptom back to potential causes. Use Grep to find all references, Read to understand the logic.

3. **Check recent changes:**
   ```bash
   git log --oneline -20 -- <affected-files>
   ```
   Was this working before? What changed? A regression means the root cause is in the diff.

4. **Reproduce:** Can you trigger the bug deterministically? If not, gather more evidence before proceeding.

5. **Check investigation history:** # ... (생략: 과거 학습 조회 설명 — 94행) ...

{{LEARNINGS_SEARCH:query=debug investigation root cause hypothesis bug fix}}

Output: **"Root cause hypothesis: ..."** — a specific, testable claim about what is wrong and why.
~~~~

📝 각 Phase는 **산출물 한 줄**("Root cause hypothesis: …")로 끝난다. 다음 Phase의 입력이 명확해진다.

## ③ 생략된 중간부 요약 (99–177행)
- 가설 키워드로 학습 재검색 (100–112행)
- **Scope Lock**: freeze로 편집 범위 잠금 (116–142행, 03-composition 참고)
- **Phase 2 Pattern Analysis**: 경쟁 조건·null 전파·캐시 등 6개 패턴 표 (148–174행)

## ④ Phase 3: 3-strike 규칙 (178–199행)

~~~~markdown
## Phase 3: Hypothesis Testing

Before writing ANY fix, verify your hypothesis.

1. **Confirm the hypothesis:** Add a temporary log statement, assertion, or debug output at the suspected root cause. Run the reproduction. Does the evidence match?

2. **If the hypothesis is wrong:** # ... (생략: 외부 검색 전 민감정보 제거 지시 — 184행) ... Then return to Phase 1. Gather more evidence. Do not guess.

3. **3-strike rule:** If 3 hypotheses fail, **STOP**. Use AskUserQuestion:
   ```
   3 hypotheses tested, none match. This may be an architectural issue
   rather than a simple bug.

   A) Continue investigating — I have a new hypothesis: [describe]
   B) Escalate for human review — this needs someone who knows the system
   C) Add logging and wait — instrument the area and catch it next time
   ```

**Red flags** — if you see any of these, slow down:
- "Quick fix for now" — there is no "for now." Fix it right or escalate.
- Proposing a fix before tracing data flow — you're guessing.
- Each fix reveals a new problem elsewhere — wrong layer, not wrong code.
~~~~

📝 **중단 조건을 숫자로**(3회) 정하고, 멈춘 뒤 사용자에게 줄 **선택지까지 미리 작성**해 둔다. "Red flags"는 모델이 스스로 합리화할 때 쓰는 문장을 미리 차단한다.

## ⑤ Phase 4–5: 영향 범위 확인과 정형 보고 (203–245행 중 발췌)

~~~~markdown
3. **Write a regression test** that:
   - **Fails** without the fix (proves the test is meaningful)
   - **Passes** with the fix (proves the fix works)

4. **Run the full test suite.** Paste the output. No regressions allowed.

5. **If the fix touches >5 files:** Use AskUserQuestion to flag the blast radius:
# ... (생략: 선택지 A/B/C — 218–223행) ...

## Phase 5: Verification & Report
# ... (생략 — 228–232행) ...
```
DEBUG REPORT
════════════════════════════════════════
Symptom:         [what the user observed]
Root cause:      [what was actually wrong]
Fix:             [what was changed, with file:line references]
Evidence:        [test output, reproduction attempt showing fix works]
Regression test: [file:line of the new test]
Related:         [TODOS.md items, prior bugs in same area, architectural notes]
Status:          DONE | DONE_WITH_CONCERNS | BLOCKED
════════════════════════════════════════
```
~~~~

## ⑥ 규칙 요약 (259–268행)

```markdown
## Important Rules

- **3+ failed fix attempts → STOP and question the architecture.** Wrong architecture, not failed hypothesis.
- **Never apply a fix you cannot verify.** If you can't reproduce and confirm, don't ship it.
- **Never say "this should fix it."** Verify and prove it. Run the tests.
- **If fix touches >5 files → AskUserQuestion** about blast radius before proceeding.
- **Completion status:**
  - DONE — root cause found, fix applied, regression test written, all tests pass
  - DONE_WITH_CONCERNS — fixed but cannot fully verify (e.g., intermittent bug, requires staging)
  - BLOCKED — root cause unclear after investigation, escalated
```

## 템플릿 268줄 → 생성본 704줄: 무엇이 늘었나

`investigate/SKILL.md`의 제목 구조(`grep '^#'`)로 확인한 결과:

| 생성본 행 | 내용 | 출처 |
|---|---|---|
| 60 | `## When to invoke this skill` | description에서 분리(catalog trim) |
| 70–412 | Preamble, AskUserQuestion Format, Voice, Context Recovery, Completeness Principle, Confusion Protocol, Completion Status Protocol, Telemetry 등 약 20개 섹션 | `{{PREAMBLE}}` 1줄 |
| 446 | `## Prior Learnings` | `{{LEARNINGS_SEARCH:…}}` |
| 532 | `## Web research runs in Aside` | `{{ASIDE_RESEARCH}}` |
| 666 | `## Capture Learnings` | `{{LEARNINGS_LOG}}` |

📝 스킬 고유 로직은 약 200줄이고, 나머지는 **모든 스킬이 공유하는 행동 규약**이다. 스킬이 많아지면 이 공통부를 템플릿으로 분리할 이유가 생긴다(→ 05).

## 스킬 제작자를 위한 교훈
- 맨 위에 **한 줄짜리 Iron Law**를 둬라. 모델이 우선순위를 잃지 않는다.
- Phase마다 **입력·행동·산출물**을 정하고, 산출물 형식("Root cause hypothesis: …")을 지정하라.
- **멈춤 조건을 숫자로**(3회 실패, 5개 파일 초과) 정하고, 멈췄을 때 보여 줄 선택지를 미리 써 둬라.
- 완료 상태를 `DONE / DONE_WITH_CONCERNS / BLOCKED`처럼 **열거형**으로 정의해 "대충 끝남"을 없애라.
- "Red flags"로 모델의 자기합리화 문장을 미리 금지하라.

## 직접 해보기
워크북 **[labs/03-workflow-skill](../../workbook/labs/03-workflow-skill/)**: 팀의 반복 업무(예: PR 설명 작성, 장애 회고) 하나를 Iron Law + 3 Phase + 멈춤 조건 + 정형 보고로 스킬화.
