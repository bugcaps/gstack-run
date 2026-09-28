# 05-1. 템플릿 시스템 개요: `.tmpl` → 생성기 → `SKILL.md`

**원본:** `gstack/ARCHITECTURE.md` (314–409행 발췌)

## 이 발췌에서 배울 것
1. 스킬 수십 개가 같은 문단을 복붙하면 **drift**가 생긴다 → 템플릿 + 플레이스홀더로 해결.
2. 사람이 쓰는 부분(판단·워크플로)과 코드에서 생성하는 부분(명령 목록·공통 규약)을 분리한다.
3. 생성본은 **커밋**한다 — 스킬 로딩 시점에는 빌드 단계가 없기 때문.

## ① 문제와 해법 (314–330행)

~~~~markdown
## SKILL.md template system

### The problem

SKILL.md files tell Claude how to use the browse commands. If the docs list a flag that doesn't exist, or miss a command that was added, the agent hits errors. Hand-maintained docs always drift from code.

### The solution

```
SKILL.md.tmpl          (human-written prose + placeholders)
       ↓
gen-skill-docs.ts      (reads source code metadata)
       ↓
SKILL.md               (committed, auto-generated sections)
```

Templates contain the workflows, tips, and examples that require human judgment. Placeholders are filled from source code at build time:
~~~~

## ② 플레이스홀더 표 (332–360행 중 발췌)

```markdown
| Placeholder | Source | What it generates |
|-------------|--------|-------------------|
| `{{COMMAND_REFERENCE}}` | `commands.ts` | Categorized command table |
| `{{SNAPSHOT_FLAGS}}` | `snapshot.ts` | Flag reference with examples |
# ... (생략: Aside 관련 5개 — 336–340행) ...
| `{{PREAMBLE}}` | `gen-skill-docs.ts` | Startup block: update check, session tracking, contributor mode, AskUserQuestion format |
# ... (생략 — 342–343행) ...
| `{{BASE_BRANCH_DETECT}}` | `gen-skill-docs.ts` | Dynamic base branch detection for PR-targeting skills (ship, review, qa, plan-ceo-review) |
| `{{QA_METHODOLOGY}}` | `gen-skill-docs.ts` | Shared QA methodology block for /qa and /qa-only |
# ... (생략: 디자인·리뷰·gbrain 관련 — 346–360행) ...
```

📝 두 종류의 플레이스홀더가 있다.
- **코드에서 추출**: `COMMAND_REFERENCE` — 실제 명령 목록을 문서에 넣음 → 없는 명령은 문서에 나올 수 없다.
- **공유 문단**: `QA_METHODOLOGY` — /qa와 /qa-only가 같은 방법론을 한 곳에서 가져감.

## ③ 구조적 보장 (362행)

```markdown
This is structurally sound — if a command exists in code, it appears in docs. If it doesn't exist, it can't appear.
```

## ④ Preamble: 모든 워크플로 스킬의 공통 시작부 (380–388행 중 발췌)

```markdown
### The preamble

Most workflow skills start with a `{{PREAMBLE}}` block that runs before the skill's own logic. # ... (생략: 구현 이력 — 382행 중간) ... The startup still handles five things:

1. **Update check** — calls `gstack-update-check`, reports if an upgrade is available.
2. **Session tracking** — touches `~/.gstack/sessions/<parent-pid>` and prunes entries older than 2 hours, so concurrent-session state is observable on disk.
3. **Operational self-improvement** — at the end of every skill session, the agent reflects on failures (CLI errors, wrong approaches, project quirks) and logs operational learnings to the project's JSONL file for future sessions.
4. **AskUserQuestion format** — universal format: context, question, `RECOMMENDATION: Choose X because ___`, lettered options. Consistent across all skills.
5. **Search Before Building** — # ... (생략: 상세 — 388행) ...
```

📝 "AskUserQuestion format"을 한 곳에서 정의하므로 **모든 스킬의 질문 스타일이 일관**된다.

## ⑤ 왜 생성본을 커밋하나 (390–396행)

```markdown
### Why committed, not generated at runtime?

Three reasons:

1. **Claude reads SKILL.md at skill load time.** There's no build step when a user invokes `/browse`. The file must already exist and be correct.
2. **CI can validate freshness.** All-host generation followed by tracked-diff and untracked-output checks catches stale docs before merge; `skill:check` also validates every host's content from a clean checkout.
3. **Git blame works.** You can see when a command was added and in which commit.
```

## ⑥ 테스트 3단계 (403–409행)

```markdown
| Tier | What | Cost | Speed |
|------|------|------|-------|
| 1 — Static validation | Parse every `$B` command in SKILL.md and validate it against the registry; pin the Aside contract sentences and the render wrapper's option mapping | Free | <2s |
| 2 — E2E via `claude -p` | Spawn real Claude session, run each skill, check for errors | ~$3.85 | ~20min |
| 3 — LLM-as-judge | `claude-fable-5-1` by default scores docs on clarity/completeness/actionability | ~$0.15 | ~30s |

Tier 1 runs on every `bun run test`. Tiers 2+3 are gated behind `EVALS=1`. The idea is: catch 95% of issues for free, use LLMs only for judgment calls.
```

📝 원본 400행 주의 문구: 유료 단계의 비용·속도 추정치는 현재 모델 기본값 이전 수치다(→ 08-testing-skills).

## 스킬 제작자를 위한 교훈
- 스킬이 3개를 넘고 같은 문단이 반복되기 시작하면 템플릿화를 고려하라. 그 전엔 과하다.
- 코드와 문서가 함께 바뀌어야 하는 정보(명령 목록·플래그)는 **코드에서 생성**하라.
- 생성본을 커밋하고, CI에서 "재생성 결과 == 커밋본"을 검사하라.
- 공통 행동 규약(질문 형식, 완료 상태, 텔레메트리)은 preamble 한 곳에 모아라.

## 직접 해보기
워크북 **[labs/04-scale-up](../../workbook/labs/04-scale-up/) (a)** 전 준비: 템플릿의 문구 한 줄을 고치고 `bun run gen:skill-docs` 실행 후 `SKILL.md` diff 확인.
