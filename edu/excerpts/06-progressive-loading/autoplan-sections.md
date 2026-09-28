# 06. 점진적 로딩: `/autoplan`의 sections

**원본:** `gstack/autoplan/sections/manifest.json` (1–44행 전체 중 발췌), `gstack/autoplan/SKILL.md.tmpl` (58, 290–318행), `gstack/autoplan/SKILL.md` (852–855행), `gstack/scripts/resolvers/sections.ts` (1–73행)

## 이 발췌에서 배울 것
1. 수천 줄짜리 스킬은 **뼈대(SKILL.md) + 필요할 때 Read하는 섹션 파일**로 쪼갠다.
2. 조건부 단계(UI가 없으면 디자인 리뷰 생략)는 **섹션을 아예 읽지 않게** 해서 컨텍스트를 아낀다.
3. 같은 템플릿이 호스트에 따라 "포인터"(Claude) 또는 "인라인"(기타 호스트)으로 생성된다.

## 규모

| 파일 | 줄 수 |
|---|---|
| `autoplan/SKILL.md.tmpl` | 465 |
| `autoplan/SKILL.md` (생성된 뼈대) | 1,032 |
| `sections/*.md` 6개 합계 | 762 (ceo 188, design 124, dx 149, eng 157, phase-close 64, tasks-aggregator 80) |

📝 한 번에 1,794줄을 다 읽는 대신, 뼈대 + 해당 단계의 섹션만 읽는다.

## ① manifest: 섹션 목록과 "언제 읽나" (`manifest.json` 발췌)

```json
{
  "$schema": "https://gstack.dev/schemas/section-manifest.json",
  "skill": "autoplan",
  "version": 1,
  "note": "PASSIVE registry (v2 plan T9 / CM2). Fields are IDs, file paths, human titles, and human-readable trigger text ONLY. The skeleton's phase sequencing (Sequential Execution + the Phase 0 UI/DX scope detection) is the ONLY place that decides WHEN to read a section — Phase 2 and Phase 2.5 are conditional and their sections must NOT be read when their scope is absent; required-reads live in the E2E fixtures. No machine predicate here — see docs/designs/v2_PLAN.md:663.",
  "sections": [
    {
      "id": "ceo-phase",
      "file": "ceo-phase.md",
      "title": "Phase 1: CEO review (strategy & scope) — override rules, dual voices, required outputs",
      "trigger": "starting Phase 1 (CEO review — always runs, after the Phase 0.5 preflight)"
    },
    {
      "id": "design-phase",
      "file": "design-phase.md",
      "title": "Phase 2: design review — override rules, dual voices, 7-pass checklist",
      "trigger": "starting Phase 2 (design review — ONLY if UI scope was detected in Phase 0; skip the read entirely otherwise)"
    }
    // ... (생략: eng-phase, dx-phase, phase-close, tasks-aggregator — 19–42행, 같은 형태) ...
  ]
}
```

📝 원본 JSON의 `—`는 `—`로 저장되어 있다. manifest는 **수동적 목록**일 뿐, "언제 읽을지" 결정은 뼈대의 단계 순서가 한다(note 필드).

## ② 템플릿에서의 사용 (`autoplan/SKILL.md.tmpl` 58, 290–312행)

```markdown
{{SECTION_INDEX:autoplan}}
# 📝 ↑ 58행: manifest로부터 "상황 → 읽을 섹션" 표 생성

# ... (생략: Phase 0 등 — 59–289행) ...

## Phase 1: CEO Review (Strategy & Scope)

{{SECTION:ceo-phase}}

---

## Phase 2: Design Review (conditional — skip if no UI scope)

**Skip condition:** If UI scope was NOT detected in Phase 0, skip this phase
entirely — do NOT read its section. Send: "Phase 2 skipped — no UI scope detected."
Record the skip in ACTIVE_PLAN; it is not a completed review.

{{SECTION:design-phase}}
```

## ③ 생성 결과 (Claude 호스트, `autoplan/SKILL.md` 852–855행)

```markdown
## Phase 1: CEO Review (Strategy & Scope)

> **STOP.** Before starting Phase 1 (CEO review — always runs, after the Phase 0.5 preflight), Read `~/.claude/skills/gstack/autoplan/sections/ceo-phase.md` and execute it
> in full. Do not work from memory — that section is the source of truth for this step.
```

📝 "STOP … Read … Do not work from memory" — 모델이 섹션을 읽지 않고 **기억으로 대충 수행하는 것**을 막는 문구.

## ④ 호스트별 분기 resolver (`scripts/resolvers/sections.ts` 1–18, 56–73행)

```ts
/**
 * Section resolvers (v2 plan T9, Claude-first carve).
 *
 * A carved skill keeps its prose-heavy steps in `<skill>/sections/<id>.md`, read
 * on demand. The SAME template ships to every host, so these resolvers make the
 * carve host-aware:
 *
 *  - On CLAUDE: {{SECTION:id}} emits a STOP-Read pointer to the generated section
 *    file (the skeleton), and the section .md is generated + installed separately.
 *  - On every OTHER host: {{SECTION:id}} INLINES the section template's content,
 *    so external hosts keep the full monolith ship skill (no section files, no
 *    host-portable-path problem). Inlined content keeps its own {{RESOLVER}}
 *    tokens, which the generator's multi-pass resolve expands.
 * ... (생략: SECTION_INDEX 설명 — 15–17행) ...
 */
// ... (생략: import, manifest 로더 — 19–55행) ...
export const SECTION: ResolverFn = (ctx: TemplateContext, args?: string[]): string => {
  const id = args?.[0];
  if (!id) throw new Error('{{SECTION:id}} requires a section id');
  const entry = findSection(ctx.skillName, id);

  if (ctx.host === 'claude') {
    const sectionPath = `${ctx.paths.skillRoot}/${ctx.skillName}/sections/${entry.file}`;
    return [
      `> **STOP.** Before ${entry.trigger}, Read \`${sectionPath}\` and execute it`,
      `> in full. Do not work from memory — that section is the source of truth for this step.`,
    ].join('\n');
  }

  // Non-Claude hosts inline the section template content (monolith preserved).
  // Inner {{RESOLVER}} tokens are expanded by the generator's multi-pass resolve.
  const tmplPath = path.join(ROOT, ctx.skillName, 'sections', `${entry.file}.tmpl`);
  return fs.readFileSync(tmplPath, 'utf-8').trimEnd();
};
// 📝 이 inline 경로 때문에 05-2의 "multi-pass 치환"이 필요하다.
```

## 스킬 제작자를 위한 교훈
- SKILL.md가 500줄을 넘고 단계별로 독립적이라면 `sections/`로 쪼개는 것을 고려하라.
- 뼈대에는 **순서·조건·포인터**만, 상세 지시는 섹션에. 조건부 단계는 "읽지 마라"까지 명시하라.
- 포인터 문구에 **"Do not work from memory"**를 넣어 실제 Read를 강제하라.
- 섹션 목록(manifest)과 읽는 시점(뼈대)을 분리하면 한쪽만 고쳐도 일관성이 유지된다.

## 직접 해보기
워크북 **[labs/04-scale-up](../../workbook/labs/04-scale-up/) (b)**: 랩 3의 워크플로 스킬을 `SKILL.md`(뼈대) + `sections/phase-*.md`로 분리하고 조건부 단계 하나를 추가.
