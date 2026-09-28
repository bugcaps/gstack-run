# 10. 모델별 오버레이: 같은 스킬, 모델마다 다른 잔소리

**원본:** `gstack/model-overlays/claude.md` (1–10행), `gstack/model-overlays/fable-5.md` (1–7행), `gstack/scripts/resolvers/model-overlay.ts` (25–44, 46–69행), `gstack/SKILL.md` (78–94행)

## 이 발췌에서 배울 것
1. 같은 스킬이라도 **실행하는 모델의 약점**에 맞춘 행동 보정(nudge)을 따로 주입할 수 있다.
2. `{{INHERIT:claude}}` 한 줄로 **모델 패밀리 공통 보정 + 개별 모델 보정**을 상속 합성한다.
3. 오버레이는 항상 **"스킬 지시가 이기면 스킬이 이긴다"는 종속 선언**과 함께 래핑된다.
4. 파일이 없으면 빈 문자열 — 새 모델이 나와도 생성 파이프라인이 깨지지 않는다 (graceful degradation).

## ① 패밀리 공통 오버레이 (`model-overlays/claude.md` 1–10행 전체)

```markdown
**Todo-list discipline.** When working through a multi-step plan, mark each task
complete individually as you finish it. Do not batch-complete at the end. If a task
turns out to be unnecessary, mark it skipped with a one-line reason.

**Think before heavy actions.** For complex operations (refactors, migrations,
non-trivial new features), briefly state your approach before executing. This lets
the user course-correct cheaply instead of mid-flight.

**Dedicated tools over Bash.** Prefer Read, Edit, Write, Glob, Grep over shell
equivalents (cat, sed, find, grep). The dedicated tools are cheaper and clearer.
```

📝 Claude 패밀리 전체에 공통으로 관찰된 습관 보정 3개. 파일 하나 = 모델(패밀리) 하나.

## ② 개별 모델은 상속으로 시작 (`model-overlays/fable-5.md` 1–7행)

```markdown
{{INHERIT:claude}}

**Act when you have enough to act.** Fable 5 can over-plan on ambiguous tasks.
When you have enough information to act, act. Do not re-derive facts already
established in the conversation, re-litigate a decision the user has already made,
or narrate options you will not pursue in user-facing messages. Give a
recommendation, not an exhaustive survey. This does not apply to thinking blocks.
```

📝 첫 줄의 `{{INHERIT:claude}}` → 위 ①의 내용이 앞에 붙고, 그 뒤에 Fable 5 전용 보정("과잉 계획 성향")이 이어진다. "Fable 5 can over-plan" — **관찰된 실제 실패 모드**를 이름 붙여 고친다는 점이 핵심.

## ③ 상속을 구현하는 resolver (`scripts/resolvers/model-overlay.ts` 25–44행)

```ts
const INHERIT_RE = /^\s*\{\{INHERIT:([a-z0-9-]+(?:\.[0-9]+)*)\}\}\s*\n/;

export function readOverlay(model: string, seen: Set<string> = new Set()): string {
  if (seen.has(model)) return ''; // cycle guard
  seen.add(model);

  const filePath = path.join(OVERLAY_DIR, `${model}.md`);
  if (!fs.existsSync(filePath)) return '';

  const raw = fs.readFileSync(filePath, 'utf-8');
  const match = raw.match(INHERIT_RE);
  if (!match) return raw.trim();

  const baseModel = match[1];
  const base = readOverlay(baseModel, seen);
  const rest = raw.replace(INHERIT_RE, '').trim();

  if (!base) return rest;
  return `${base}\n\n${rest}`;
}
```

📝 20줄짜리 재귀 함수가 상속 체계 전부다. `seen` Set으로 순환 상속을 막고, 파일이 없으면 조용히 `''`. 05-2에서 본 "resolver 하나 = 함수 하나" 패턴 그대로.

## ④ 종속 선언 래퍼 (`scripts/resolvers/model-overlay.ts` 46–69행 발췌)

```ts
export function generateModelOverlay(ctx: TemplateContext): string {
  if (!ctx.model) return '';

  const content = readOverlay(ctx.model);
  if (!content) return '';

  const precedence = /* ... (생략: gpt-5.6-sol 전용 문구 분기 — 52–59행) ... */
    `The following nudges are tuned for the ${ctx.model} model family. They are
**subordinate** to skill workflow, STOP points, AskUserQuestion gates, plan-mode
safety, and /ship review gates. If a nudge below conflicts with skill instructions,
the skill wins. Treat these as preferences, not rules.`;

  return `## Model-Specific Behavioral Patch (${ctx.model})

${precedence}

${content}`;
}
```

📝 종속 선언이 오버레이 **파일이 아니라 래퍼 코드**에 있다. 파일 작성자가 깜빡해도 모든 오버레이에 항상 붙는다 — "규칙은 사람이 기억하지 말고 파이프라인이 보장하라".

## ⑤ 생성 결과 (`gstack/SKILL.md` 78–83행, claude 모델로 생성된 경우)

```markdown
## Model-Specific Behavioral Patch (claude)

The following nudges are tuned for the claude model family. They are
**subordinate** to skill workflow, STOP points, AskUserQuestion gates, plan-mode
safety, and /ship review gates. If a nudge below conflicts with skill instructions,
the skill wins. Treat these as preferences, not rules.
```

📝 `bun run gen:skill-docs`가 호스트의 기본 모델(claude/gpt)로 이 블록을 렌더링해 SKILL.md에 굽는다. 런타임 분기가 아니라 **생성 시점 분기**다 (05-1의 파이프라인 위에서 동작).

## 스킬 제작자를 위한 교훈
- 여러 모델/하네스에서 돌 스킬이라면, 모델별 차이를 스킬 본문에 섞지 말고 **오버레이 파일로 분리**하라.
- 오버레이에는 반드시 종속 선언을 붙여라 — 없으면 보정이 스킬의 STOP·게이트를 이겨버리는 사고가 난다.
- 보정 문구는 "그 모델의 관찰된 실패 모드" 단위로 써라. 추측성 일반론은 넣지 않는다 (gstack은 `test/model-overlay-*.test.ts`로 오버레이별 효과를 검증한다).
- 없는 파일 = 빈 문자열. 새 모델 추가가 "파일 하나 만들기"로 끝나게 설계하라.

## 직접 해보기 (심화 과제)
랩 4의 `gen.sh`에 `--model` 인자를 추가하고, `overlays/claude.md`와 `overlays/gpt.md` 두 파일을 만들어 `{{MODEL_OVERLAY}}` 플레이스홀더를 치환해 보자. 종속 선언 래퍼는 gen.sh 쪽에 넣을 것. `{{INHERIT:...}}`까지 구현하면 만점.
