# 03강. 워크플로 스킬과 Iron Law: The State Machine Pattern

**원본:** `gstack/investigate/SKILL.md` (전문 704줄 중 핵심 발췌), `gstack/ETHOS.md` (User Sovereignty)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. Iron Law: 원인 규명 없는 수정은 없다

주니어 엔지니어나 단순한 에이전트는 버그를 만나면 즉시 소스코드를 열어 "이거 고치면 되나?" 하고 찔러봅니다. 근본 원인을 모른 채 엉뚱한 부작용을 일으키는 최악의 안티패턴입니다.

gstack의 `/investigate` 스킬은 문서 서두에 어길 수 없는 법률을 선포합니다:

```markdown
# Iron Law

> **NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**
>
> If you have not found the root cause, you cannot fix it.
> Do NOT touch code until:
> 1. You have reproduced the bug with a minimal test or script.
> 2. You have traced the failure to its origin in the source code.
> 3. You can explain the exact sequence of events that causes the failure.
```

📝 **아키텍처 해설**:
- 에이전트의 손발을 먼저 묶는 작업입니다.
- 원인이 규명되기 전까지는 `Edit`, `Write` 도구를 호출할 수 없도록 강제함으로써, 에이전트가 탐색과 검증에만 집중하도록 만듭니다.

---

## 2. 5단계 게이트웨이 상태 머신 (The Gateway Pattern)

`/investigate`는 단일 실행이 아니라, 이전 단계의 검증 산출물이 나와야만 다음 단계 문을 열어주는 **유한 상태 머신(Finite State Machine)**입니다:

```
[Phase 1: Triage]      ──▶ 증상 정의 및 범위 격리 (산출물: 증상 리포트)
        │
[Phase 2: Reproduce]   ──▶ 최소 실패 재현 스크립트 작성 (산출물: 실패 로그)
        │
[Phase 3: Root Cause]  ──▶ 소스코드 행 단위 원인 추적 (산출물: 인과관계 설명)
        │
[Phase 4: Minimal Fix] ──▶ 외과 수술적 정밀 코드 수정 (산출물: git diff)
        │
[Phase 5: Verify]      ──▶ 재현 스크립트 통과 & 회귀 테스트 검증 (완료)
```

---

## 3. 무한 루프 탈출용 중단 조건 (3-Strike Rule)

자율 에이전트가 가장 많은 토큰을 낭비하고 코드를 망치는 순간은 "틀린 가설을 끊임없이 반복할 때"입니다.

`gstack/investigate/SKILL.md` 발췌:
```markdown
## Abort Conditions (When to STOP)

- **The 3-Strike Rule**: If your hypothesis fails to explain or reproduce the bug after 3 attempts:
  1. STOP immediately. Do NOT attempt a 4th hypothesis.
  2. Document the 3 failed hypotheses and the actual evidence observed.
  3. Call `AskUserQuestion` to present your findings and ask for domain guidance.
```

📝 **핵심 엔지니어링 교훈**:
- 똑똑한 에이전트를 만드는 것보다 **"언제 멈춰야 하는지 아는 에이전트"**를 만드는 것이 훨씬 어렵고 중요합니다.
- 3회 실패 시 작업을 멈추고 사람(`AskUserQuestion`)을 루프 안으로 끌어들임으로써 무한 루프를 원천 차단합니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab03-workflow](../../03_workbook/lab03-workflow/)**: 3단계 게이트웨이와 Iron Law, 3-Strike 탈출 조건을 갖춘 `module-analyst` 스킬을 직접 설계합니다.
