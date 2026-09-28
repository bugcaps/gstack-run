# 11강 [심화]. 컨텍스트 2층 예산제도: The Two-Tier Budgeting Pattern

**원본:** `gstack/scripts/validate.sh` (budget check), `gstack/test/catalog-budget.test.ts`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 컨텍스트를 한정된 자원으로 다루는 태도

스킬 목록을 아무 생각 없이 늘리면, 대화가 시작되기도 전에 수천~수만 토큰이 사라집니다.  
gstack은 컨텍스트 윈도우를 **"돈과 직결되는 한정된 물리적 자원"**으로 규정하고, 2단계 예산 제도를 운영합니다:

```
[1층: 카탈로그 예산 (상주)] ──▶ 하드 게이트 (글자 수 1자만 초과해도 CI 빌드 실패)
[2층: 본문 지시문 (온디맨드)] ──▶ 소프트 게이트 (호출될 때만 읽히므로 유연한 관리)
```

---

## 2. 래칫(Ratchet) 테스트와 하드 예산 검증

`gstack/test/catalog-budget.test.ts` 소스코드 발췌:

```typescript
// catalog-budget.test.ts
import { describe, it, expect } from "bun:test";
import { readdirSync, readFileSync } from "fs";

describe("Catalog Budget Ratchet", () => {
  const MAX_DESCRIPTION_CHARS = 250;
  const MAX_TOTAL_CATALOG_TOKENS = 2500;

  it("enforces strict per-skill description limits", () => {
    const skills = readdirSync("~/.claude/skills");
    let totalChars = 0;

    for (const skill of skills) {
      const content = readFileSync(`~/.claude/skills/${skill}/SKILL.md`, "utf8");
      const descMatch = content.match(/description:\s*(.*?)\n[a-z-]/s);
      if (descMatch) {
        const desc = descMatch[1].trim();
        expect(desc.length).toBeLessThanOrEqual(MAX_DESCRIPTION_CHARS);
        totalChars += desc.length;
      }
    }
  });
});
```

📝 **래칫(Ratchet) 엔지니어링의 원리**:
- **래칫(역회전 방지 톱니)**이란: 예산은 한 번 줄이면 다시 늘어날 수 없도록 테스트로 못 박는 기법입니다.
- 개발자가 새로운 스킬을 추가할 때 기존 스킬의 설명을 줄이거나, 정해진 글자 수 한도 내에서만 간결하게 작성하도록 강제합니다.
- 시스템의 지속 가능성을 엔지니어의 '의지'가 아니라 **'CI 파이프라인의 에러 코드'**로 지켜냅니다.
