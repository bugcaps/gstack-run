# 05-2. 생성기와 resolver 코드: `gen-skill-docs.ts` + `learnings.ts`

**원본:** `gstack/scripts/gen-skill-docs.ts` (1149줄 중 1–10, 631–696, 787–864행), `gstack/scripts/resolvers/learnings.ts` (1–66행), `gstack/scripts/resolvers/types.ts` (117행), `gstack/scripts/resolvers/index.ts` (69, 113–114행)

## 이 발췌에서 배울 것
1. 치환 엔진의 핵심은 정규식 한 줄 + **이름 → 함수** 레지스트리다.
2. 생성기는 **실패를 빌드 에러로** 만든다(모르는 플레이스홀더, 남은 플레이스홀더, PREAMBLE 중복).
3. resolver는 인자를 받을 수 있고, 인자가 bash에 들어가면 **입력 검증**이 필요하다.

## ① 파이프라인 한 줄 요약 (1–10행)

```ts
#!/usr/bin/env bun
/**
 * Generate SKILL.md files from .tmpl templates.
 *
 * Pipeline:
 *   read .tmpl → find {{PLACEHOLDERS}} → resolve from source → format → write .md
 *
 * Supports --dry-run: generate to memory, exit 1 if different from committed file.
 * Used by skill:check and CI freshness checks.
 */
```

## ② resolver 타입과 레지스트리

```ts
// 📝 출처: scripts/resolvers/types.ts 117행
export type ResolverFn = (ctx: TemplateContext, args?: string[]) => string;
// 📝 resolver = (스킬 컨텍스트, 인자) → 삽입할 문자열. 이게 전부다.
```

```ts
// 📝 출처: scripts/resolvers/index.ts 69, 113–114행 (RESOLVERS 객체 일부)
  PREAMBLE: generatePreamble,
// ... (생략: 다른 resolver 등록 — 70–112행) ...
  LEARNINGS_SEARCH: generateLearningsSearch,
  LEARNINGS_LOG: generateLearningsLog,
```

## ③ 치환 엔진 (`gen-skill-docs.ts` 637–696행)

```ts
/**
 * A second {{PREAMBLE}} in one template re-expands the entire ~12K-token
 * preamble mid-document (#2508/#2362 — a PROSE mention of the macro in
 * spec/SKILL.md.tmpl expanded it a second time, +43KB per /spec load).
 * Resolution is context-blind, so any second occurrence — code fence, prose,
 * anywhere — is a generation error, never intentional. Throw at render time
 * so the mistake cannot reach a generated SKILL.md again.
 */
export function assertSinglePreamble(tmplContent: string, relTmplPath: string): void {
  const count = (tmplContent.match(/\{\{PREAMBLE\}\}/g) || []).length;
  if (count > 1) {
    throw new Error(
      `${relTmplPath} contains {{PREAMBLE}} ${count} times — a template may reference it `
      + `at most once (each occurrence expands the full preamble; see #2508/#2362). `
      + `Refer to "the preamble" in prose instead of the macro.`,
    );
  }
}
// 📝 실제 사고: 문서 속 "설명용" {{PREAMBLE}} 언급까지 치환되어 /spec 로드마다 +43KB.
// 📝    → 컨텍스트 비용 사고를 빌드 단계에서 막는 가드.

function resolvePlaceholders(
  tmplContent: string,
  ctx: TemplateContext,
  hostConfig: HostConfig,
  relTmplPath: string,
  options: RenderOptions,
): string {
  assertSinglePreamble(tmplContent, relTmplPath);
  // ... (생략: gbrain 감지 관련 주석 — 664–666행) ...
  const suppressed = effectiveSuppressedResolvers(hostConfig, options);
  const onePass = (input: string): string =>
    input.replace(/\{\{(\w+(?::[^}]+)?)\}\}/g, (_match, fullKey) => {
      const parts = fullKey.split(':');
      const resolverName = parts[0];
      const args = parts.slice(1);
      if (suppressed.has(resolverName)) return '';
      const resolve = RESOLVERS[resolverName];
      if (!resolve) throw new Error(`Unknown placeholder {{${resolverName}}} in ${relTmplPath}`);
      return args.length > 0 ? resolve(ctx, args) : resolve(ctx);
    });
  // 📝 {{NAME}} 또는 {{NAME:arg}} → RESOLVERS[NAME](ctx, [arg])
  // 📝    호스트가 지원하지 않는 resolver(suppressed)는 빈 문자열로.

  // Multi-pass: a resolver may emit content that itself contains {{TOKENS}} — the
  // {{SECTION:id}} resolver inlines a section template (with its own resolvers)
  // for non-Claude hosts. .replace() doesn't re-scan inserted text, so loop until
  // the output stabilizes. Bounded to avoid an infinite loop if a resolver ever
  // emits its own placeholder; 6 passes is far more nesting than any skill needs.
  let content = tmplContent;
  for (let pass = 0; pass < 6; pass++) {
    const next = onePass(content);
    if (next === content) break;
    content = next;
  }

  const remaining = content.match(/\{\{(\w+(?::[^}]+)?)\}\}/g);
  if (remaining) {
    throw new Error(`Unresolved placeholders in ${relTmplPath}: ${remaining.join(', ')}`);
  }
  return content;
}
```

## ④ 템플릿 1개 처리 순서 (`processTemplate`, 787–864행 요약 발췌)

```ts
  const tmplContent = fs.readFileSync(tmplPath, 'utf-8').replace(/\r\n/g, '\n');
  // 📝 795행: Windows CRLF → LF 정규화. 안 하면 \n 가정 정규식이 조용히 실패해 CI와 결과가 달라진다.
// ... (생략: 출력 경로 계산 — 796–817행) ...
  let content = resolvePlaceholders(tmplContent, ctx, currentHostConfig, relTmplPath, options);
// ... (생략: voice trigger 처리 — 821–828행) ...
  if (host === 'claude') {
    content = transformFrontmatter(content, host);
    // 📝 Claude용: sensitive 등 불필요 필드 제거
  } else {
    const result = processExternalHost(content, tmplContent, host, skillDir, postProcessDescription, ctx, options, extractedName || undefined);
    // ... (생략 — 838–841행) ...
  }

  // Prepend generated header (after frontmatter)
  const header = GENERATED_HEADER.replace('{{SOURCE}}', path.basename(tmplPath));
// ... (생략: 헤더 삽입 위치 계산 — 846–852행) ...

  // Catalog trim (Claude only — external hosts have their own frontmatter shapes)
  if (host === 'claude' && options.catalogMode === 'trim') {
    const trimmed = applyCatalogTrim(content, skillName);
    if (trimmed) content = trimmed.content;
  }
  // 📝 description 첫 문장만 frontmatter에 남기고 "Use when…"은 본문으로 이동 (01-anatomy 참고)
```

📝 흐름: **읽기(LF 정규화) → 치환 → 호스트별 frontmatter 변환 → AUTO-GENERATED 헤더 → catalog trim**

## ⑤ resolver 예시: `LEARNINGS_SEARCH` (`scripts/resolvers/learnings.ts` 17–66행 발췌)

```ts
// Whitelist for query= macro values. Allows alphanumeric, space, hyphen, underscore.
// Anything else (e.g. $, backticks, quotes, ;) is a shell-injection vector when the
// emitted bash interpolates the value into `--query "${queryArg}"`. Static template
// queries hand-written in gstack are safe, but the resolver API must defend against
// future contributors writing dangerous values.
const QUERY_SAFE_RE = /^[A-Za-z0-9 _-]+$/;

export function generateLearningsSearch(ctx: TemplateContext, args?: string[]): string {
  // ... (생략: 빈 query 처리 주석 — 25–26행) ...
  const queryArg = (args || [])
    .filter(a => a.startsWith('query='))
    .map(a => a.slice(6))
    .filter(Boolean)[0];
  if (queryArg && !QUERY_SAFE_RE.test(queryArg)) {
    throw new Error(
      `{{LEARNINGS_SEARCH:query=...}} value must match ${QUERY_SAFE_RE} (alphanumeric, space, hyphen, underscore). Got: ${JSON.stringify(queryArg)}`
    );
  }
  const queryFlag = queryArg ? ` --query "${queryArg}"` : '';
  // 📝 템플릿 인자가 생성될 bash에 그대로 들어가므로 화이트리스트 검증

  if (getHostConfig(ctx.host).learningsMode === 'basic') {
    // ... (생략: 기본 호스트용 단순 버전 — 39–51행) ...
  }

  return `## Prior Learnings

Search for relevant learnings from previous sessions:

\`\`\`bash
_CROSS_PROJ=$(${ctx.paths.binDir}/gstack-config get cross_project_learnings 2>/dev/null || echo "unset")
echo "CROSS_PROJECT: $_CROSS_PROJ"
if [ "$_CROSS_PROJ" = "true" ]; then
  ${ctx.paths.binDir}/gstack-learnings-search --limit 10${queryFlag} --cross-project 2>/dev/null || true
else
  ${ctx.paths.binDir}/gstack-learnings-search --limit 10${queryFlag} 2>/dev/null || true
fi
\`\`\`
// ... (생략: 최초 1회 AskUserQuestion 동의 절차 — 67행 이후) ...
```

📝 `ctx.paths.binDir`로 **호스트마다 다른 설치 경로**가 들어간다. 같은 템플릿이 Claude/Codex/Cursor용으로 각각 올바른 경로를 갖게 되는 원리.

### 템플릿에서의 사용 (`investigate/SKILL.md.tmpl` 96행)
```markdown
{{LEARNINGS_SEARCH:query=debug investigation root cause hypothesis bug fix}}
```

## 스킬 제작자를 위한 교훈
- 템플릿 엔진은 크게 만들 필요 없다: `정규식 + Record<string, fn>` 이면 충분하다.
- **모르는/남은 플레이스홀더는 빌드 실패**로 처리하라. 조용히 남으면 모델이 `{{...}}`를 그대로 읽는다.
- 큰 블록(preamble)이 중복 삽입되면 컨텍스트 비용이 폭증한다 → 개수 가드.
- resolver 인자가 셸 코드로 들어가면 화이트리스트로 검증하라.
- Windows 개발자가 있다면 CRLF 정규화를 입구에서 하라.

## 직접 해보기
워크북 **[labs/04-scale-up](../../workbook/labs/04-scale-up/) (a)**: 30줄 이내의 미니 생성기(`{{COMMON}}` 치환 + 남은 플레이스홀더 시 에러)를 만들어 내 스킬 2개에 공통 문단 주입.
