# 12. 컨텍스트 예산: 스킬은 공짜가 아니다 — 카탈로그 예산과 래칫 테스트

**원본:** `gstack/test/catalog-budget.test.ts` (6–46, 95–117행), `gstack/CLAUDE.md` "Token ceiling" 절

## 이 발췌에서 배울 것
1. 스킬의 비용은 두 층이다: **항상 로드되는 카탈로그**(모든 name+description, 매 세션) vs **호출 시에만 로드되는 본문**.
2. 카탈로그는 **테스트로 강제되는 하드 예산**, 본문은 경고만 하는 소프트 예산 — 층에 따라 강제 수준이 다르다.
3. 예산 숫자는 **래칫(ratchet)**: 늘릴 때마다 같은 커밋에 근거(측정 방법·날짜·무엇이 늘렸는지)를 남긴다.
4. 실패 메시지에 **해결 절차를 그대로 실어** 미래의 기여자(사람이든 AI든)가 헤매지 않게 한다.

## ① 왜 카탈로그가 하드 게이트인가 (`test/catalog-budget.test.ts` 6–13행)

```ts
/**
 * Aggregate discovery-surface budget: the sum of every skill's frontmatter
 * `name` + `description` is what EVERY host loads at discovery, every session.
 *
 * This is the missing enforcement layer over the existing catalog-trim
 * mechanism: `applyCatalogTrim` in scripts/gen-skill-docs.ts (~line 865)
 * shapes each description, and the 160KB per-file warn (~line 1015) covers
 * BODY size — neither caps the aggregate frontmatter the catalog is made of.
 */
```

📝 1회차에서 배운 대로 description은 라우팅의 전부다 — 그래서 **모든 스킬의 description이 모든 세션에 항상 로드**된다. 62개 스킬이면 티끌이 모여 매 대화의 고정 세금이 된다.
📝 반면 본문(SKILL.md)은 호출될 때만 로드되므로 160KB **경고**로 충분하다 (gstack/CLAUDE.md: "watch for feature bloat" guardrail, not a hard gate). 층이 다르면 강제 수준도 달라야 한다.

## ② 예산 숫자에는 유도 과정이 붙는다 (`test/catalog-budget.test.ts` 19–39행 발췌)

```ts
/**
 * Budget derivation (re-derive it, do not trust the number):
 *   ref     this commit
 *   method  for each authored skill (test/helpers/skill-census.ts
 *           authoredSkills — symlink-deduped, root router excluded) plus the
 *           root router's `_gstack-command` alias frontmatter as one separate
 *           line item, run parseFrontmatter() below and sum
 *           Buffer.byteLength(name) + Buffer.byteLength(description);
 *           token-equivalents = ceil(bytes / 4).
 *   ref     deslop-shared-libs addition on base a6b3a575 (2026-09-16)
 *   result  pre-addition aggregate 4,593 bytes; deslop-shared-libs adds
 *           82 bytes (name + concise description), yielding 4,675 bytes
 *           = 1,169 token-equivalents including the root router alias.
 * New-skill ratchet: previous ceiling 1,150 + ceil(82 / 4) = 1,171
 * token-equivalents (4,684 bytes), leaving 9 bytes.
 */
const CATALOG_BUDGET_TOKEN_EQUIVALENTS = 1_171;

// Largest today: design-consultation at 229 bytes. A description that needs
// more than 260 bytes is a body paragraph, not a catalog entry.
const PER_SKILL_BYTE_CAP = 260;
```

📝 "re-derive it, do not trust the number" — 매직 넘버가 아니라 **측정 방법 + 이력**이 함께 커밋된다. 예산을 1,150 → 1,171로 올린 커밋이 "무엇이 82바이트를 추가했는지"까지 기록.
📝 개별 캡의 근거도 한 줄로: "260바이트가 넘는 description은 카탈로그 항목이 아니라 본문 문단이다."

## ③ 실패 메시지가 곧 문서다 (`test/catalog-budget.test.ts` 41–46, 96–105행 발췌)

```ts
const RATCHET_PROTOCOL =
  'Adding a skill? Re-measure with: bun test test/catalog-budget.test.ts ' +
  '(the failure prints the new total). Update CATALOG_BUDGET_TOKEN_EQUIVALENTS ' +
  'AND the derivation comment (ref/date/value/which skill moved it) in the ' +
  'SAME commit. Growing an existing description? Trim it instead — the ' +
  'catalog is what every host loads at discovery, every session.';

    expect(
      estimatedTokens,
      `Catalog is ${estimatedTokens} token-equivalents (${totalBytes} bytes), ` +
        `${delta} over the ${CATALOG_BUDGET_TOKEN_EQUIVALENTS} budget. ${RATCHET_PROTOCOL}`
    ).toBeLessThanOrEqual(CATALOG_BUDGET_TOKEN_EQUIVALENTS);
```

📝 테스트가 깨졌을 때 나오는 메시지에 초과량 + 재측정 명령 + 갱신 절차가 다 들어 있다. 8회차(테스팅)의 무료 정적 검증과 같은 계층이지만, 검증 대상이 문법이 아니라 **비용**이다.

## ④ 본문 쪽 예산: 래칫의 확장 (gstack/CLAUDE.md 발췌)

```markdown
The context-budget ratchet (`test/context-budget-ratchet.test.ts`, free, runs
in `bun run test`) pins ABSOLUTE ceilings on two more ledgers: the always-on
FULL-frontmatter aggregate (catalog-budget counts only name+description) and
each skill's per-invocation eager tokens (SKILL.md + forced-read references
...), graded against `test/fixtures/context-budget.json`. A skill that grows
past its ceiling fails; a new skill fails until it's consciously budgeted.
```

📝 스킬별 "호출 시 즉시 읽게 되는 토큰"(본문 + 강제 Read 참조 문서)에도 스킬별 천장이 fixture로 고정된다. **새 스킬은 예산을 의식적으로 배정하기 전까지 테스트가 실패** — 비용 결정을 잊을 수 없게 만든 설계. 6회차의 점진적 로딩(sections)은 바로 이 per-invocation 예산을 줄이는 수단이다.

## 스킬 제작자를 위한 교훈
- description을 쓸 때 "항상 로드되는 공간"임을 기억하라. 라우팅에 필요한 표현만 남기고, 설명은 본문으로 보내라.
- 스킬이 3~4개만 되어도 카탈로그 합계를 재 보라: `이름+description 바이트 합 ÷ 4 ≒ 매 세션 고정 토큰`.
- 예산은 상수로 두지 말고 **테스트 + 유도 주석 + 갱신 절차**로 커밋하라. 늘어나는 것 자체가 아니라 "모르고 늘어나는 것"이 적이다.
- 실패 메시지에 해결 절차를 실어라. 게이트는 막는 것보다 **고치는 길을 알려줄 때** 유지된다.

## 직접 해보기 (심화 과제)
랩 4의 `validate.sh`에 검사 2개를 추가해 보자: (a) 각 스킬의 name+description 합이 260바이트 이하, (b) 전체 합이 예산 파일(`budget.txt`)의 숫자 이하 — 초과 시 "새 합계와 갱신 방법"을 출력. 스킬 하나의 description을 일부러 길게 늘려 게이트가 절차를 안내하며 실패하는지 확인.
