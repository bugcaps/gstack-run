# 08. 스킬 테스트: 무료 정적 검증 vs 유료 LLM eval

**원본:** `gstack/package.json` (22, 26, 29, 41행), `gstack/test/skill-parser.test.ts` (258줄 중 1–31, 197–226행), `gstack/test/skill-validation.test.ts` (2,217줄 중 83–96, 319–336, 620–678행), `gstack/test/hook-scripts.test.ts` (12–25, 61–67, 141–159행), `gstack/test/skill-routing-e2e.test.ts` (16–18, 195–215행)

## 이 발췌에서 배울 것
1. 스킬(=Markdown)도 테스트 대상이다: **문서 속 명령이 실제로 존재하는가**를 파싱해서 검증한다.
2. hook은 **stdin JSON을 넣고 stdout JSON을 검사**하는 일반 단위 테스트로 검증한다.
3. "이 프롬프트에 이 스킬이 호출되는가"(라우팅)는 실제 모델을 돌리는 **유료 eval**로 따로 분리한다.

## 테스트 층 구분 (`package.json`)

```jsonc
"gen:skill-docs": "bun run scripts/gen-skill-docs.ts",          // 📝 22행
"test": "bun run scripts/test-free-shards.ts",                   // 26행 📝 무료: 매번 실행
"test:evals": "EVALS=1 bun test --retry 1 --concurrent --max-concurrency ${EVALS_CONCURRENCY:-15} test/skill-llm-eval*.test.ts test/skill-e2e-*.test.ts test/skill-routing-e2e.test.ts test/codex-e2e*.test.ts test/gemini-e2e.test.ts test/llm-judge-recommendation.test.ts test/carve-section-loading*.test.ts",  // 29행 📝 유료: EVALS=1일 때만
"skill:check": "bun run scripts/skill-check.ts",                 // 41행 📝 생성본 최신 여부
```

| 층 | 무엇을 | 비용 | 언제 |
|---|---|---|---|
| 정적 검증 | 문서 파싱, 플레이스홀더 잔존, 금지 패턴 | 무료, 수 초 | 모든 커밋 |
| hook 단위 테스트 | 입력 JSON → 결정 JSON | 무료 | 모든 커밋 |
| E2E / 라우팅 | 실제 Claude 세션 실행 | 유료 | `EVALS=1` |
| LLM-as-judge | 문서 품질 채점 | 유료 | `EVALS=1` |

## ① 문서 파서 테스트 (`skill-parser.test.ts` 16–31, 213–226행)

```ts
describe('extractBrowseCommands', () => {
  test('extracts $B commands from bash code blocks', () => {
    const p = writeFixture('basic.md', [
      '# Test',
      '```bash',
      '$B goto https://example.com',
      '$B snapshot -i',
      '```',
    ].join('\n'));
    const cmds = extractBrowseCommands(p);
    expect(cmds).toHaveLength(2);
    expect(cmds[0].command).toBe('goto');
    expect(cmds[0].args).toEqual(['https://example.com']);
    expect(cmds[1].command).toBe('snapshot');
    expect(cmds[1].args).toEqual(['-i']);
  });
  // ... (생략: 비-bash 블록 무시, 줄 번호 추적 등 — 33–195행) ...

  test('invalid commands flagged in result', () => {
    const p = writeFixture('invalid.md', [
      '```bash',
      '$B goto https://example.com',
      '$B explode',
      '$B halp',
      '```',
    ].join('\n'));
    const result = validateSkill(p);
    expect(result.valid).toHaveLength(1);
    expect(result.invalid).toHaveLength(2);
    expect(result.invalid[0].command).toBe('explode');
    expect(result.invalid[1].command).toBe('halp');
  });
  // 📝 스킬 문서에 없는 명령(explode, halp)을 쓰면 테스트가 잡는다.
  // 📝    모델이 문서대로 실행했다가 에러 나는 상황을 사전 차단.
```

## ② 실제 스킬 문서 검증 (`skill-validation.test.ts`)

### 명령 레지스트리 대조 (83–96행)

```ts
describe('SKILL.md command validation', () => {
  // ... (생략: 설명 주석 — 84–87행) ...
  test('top-level SKILL.md is a router with no browse body (P2)', () => {
    const md = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
    expect(md).not.toContain('gstack browse: QA Testing'); // browse body removed
    expect(md).toContain('## Route first'); // router head present
    expect(md).toContain('invoke `/investigate`'); // routing rules present
    const result = validateSkill(path.join(ROOT, 'SKILL.md'));
    expect(result.invalid).toHaveLength(0); // no INVALID browse commands
    expect(result.valid.length).toBe(0); // and no browse commands at all — it routes, not browses
  });
  // 📝 "이 문서에는 반드시 X가 있고 Y는 없어야 한다" → 구조 회귀 방지
```

### 생성본 신선도 (319–336행)

```ts
describe('Generated SKILL.md freshness', () => {
  test('no unresolved {{placeholders}} in generated SKILL.md', () => {
    const content = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
    const unresolved = content.match(/\{\{\w+\}\}/g);
    expect(unresolved).toBeNull();
  });
  // ... (생략: browse/SKILL.md 동일 검사 — 326–330행) ...
  test('generated SKILL.md has AUTO-GENERATED header', () => {
    const content = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
    expect(content).toContain('AUTO-GENERATED');
  });
});
```

### 금지 패턴: 브랜치 이름 하드코딩 (620–678행 발췌)

```ts
describe('No hardcoded branch names in SKILL templates', () => {
  // ... (생략: 대상 템플릿 9개 목록 — 621–631행) ...

  // Patterns that indicate hardcoded 'main' in git commands
  const gitMainPatterns = [
    /\bgit\s+diff\s+(?:origin\/)?main\b/,
    /\bgit\s+log\s+(?:origin\/)?main\b/,
    /\bgit\s+fetch\s+origin\s+main\b/,
    /\bgit\s+merge\s+origin\/main\b/,
    /\borigin\/main\b/,
  ];
  // ... (생략: 허용 문구 목록, 줄 단위 검사 루프 — 642–677행) ...
```

📝 스킬 문서가 `main`을 가정하면 `master`/`develop` 저장소에서 잘못 동작한다. **스킬 작성 규칙을 테스트로 강제**하는 사례.

## ③ hook 단위 테스트 (`hook-scripts.test.ts` 12–25, 61–67, 141–159행)

```ts
function runHook(scriptPath: string, input: object, env?: Record<string, string>, cwd?: string): { exitCode: number; output: any; raw: string } {
  const result = spawnSync('bash', [scriptPath], {
    input: JSON.stringify(input),
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, ...env },
    cwd,
    timeout: 5000,
  });
  const raw = result.stdout.toString().trim();
  let output: any = {};
  try {
    output = JSON.parse(raw);
  } catch {}
  return { exitCode: result.status ?? 1, output, raw };
}
// 📝 Claude Code가 하는 일을 그대로 흉내: bash로 실행, stdin에 JSON, stdout을 JSON 파싱

// ... (생략 — 26–60행) ...
function carefulInput(command: string) {
  return { tool_input: { command } };
}

function freezeInput(filePath: string) {
  return { tool_input: { file_path: filePath } };
}
// ... (생략 — 68–140행) ...
    test('rm -rf /var/data warns with recursive delete message', () => {
      const { exitCode, output } = runHook(CAREFUL_SCRIPT, carefulInput('rm -rf /var/data'));
      expect(exitCode).toBe(0);
      expect(output.hookSpecificOutput?.permissionDecision).toBe('ask');
      expect(output.hookSpecificOutput?.permissionDecisionReason).toContain('recursive delete');
    });
    // ... (생략: rm -r 케이스 — 148–153행) ...
    test('rm -rf node_modules allows (safe exception)', () => {
      const { exitCode, output } = runHook(CAREFUL_SCRIPT, carefulInput('rm -rf node_modules'));
      expect(exitCode).toBe(0);
      expect(output.hookSpecificOutput?.permissionDecision).toBeUndefined();
    });
```

📝 같은 파일에 `rm -rf /; rm -rf node_modules`(체인), `` rm -rf `./wipe-all`/node_modules ``(치환), `rm -R /`(HIGH deny) 같은 **우회 시도 케이스**가 이어진다(177–267행). 버그 하나 고칠 때마다 우회 케이스를 추가하는 방식.

## ④ 라우팅 E2E: 유료, 기본은 skip (`skill-routing-e2e.test.ts` 16–18, 195–215행)

```ts
// Skip unless EVALS=1.
const evalsEnabled = !!process.env.EVALS;
const describeE2E = evalsEnabled ? describe : describe.skip;
// ... (생략 — 19–194행) ...
      const testName = 'journey-ideation';
      const expectedSkill = 'office-hours';
      const result = await runSkillTest({
        prompt: "I've been thinking about building a waitlist management tool for restaurants. # ... (생략: 프롬프트 나머지) ...",
        workingDirectory: tmpDir,
        // Turn/tool cap (2026-08 audit): only the FIRST Skill call is
        // asserted, so 5 turns of Read/Bash/Glob/Grep was pure spend — the
        // session ends at the routing decision, roughly halving each
        // journey's cost.
        maxTurns: 2,
        allowedTools: ['Skill', 'Read'],
        timeout: JUDGE_MS,
        testName,
        runId,
      });

      const skillCalls = result.toolCalls.filter(tc => tc.tool === 'Skill');
      const actualSkill = skillCalls.length > 0 ? skillCalls[0]?.input?.skill : undefined;
      // 📝 "사용자가 스킬 이름을 말하지 않아도 description만으로 office-hours가 선택되는가"
```

📝 비용 절감 요령: 검증 대상이 "첫 Skill 호출"뿐이므로 `maxTurns: 2`, 도구도 `Skill`, `Read`만 허용.

## 스킬 제작자를 위한 교훈
- 스킬 문서도 코드처럼 테스트하라. 최소한 **"문서 속 명령/경로가 실제로 존재하는가"**는 무료로 검사 가능하다.
- hook은 `spawnSync('bash', [hook], { input: JSON })` 한 함수로 쉽게 테스트된다. **우회 케이스를 누적**하라.
- 스킬 작성 규칙(브랜치 하드코딩 금지 등)은 리뷰가 아니라 **테스트로** 강제하라.
- description이 제대로 라우팅되는지는 실제 모델로만 알 수 있다 → `EVALS=1` 같은 스위치 뒤에 두고, 턴·도구를 최소화해 비용을 줄여라.

## 직접 해보기
워크북 **[labs/04-scale-up](../../workbook/labs/04-scale-up/) (c)** 검증 스크립트 실습 후 **심화 과제**: 랩 2의 hook에 대해 `runHook` 방식 테스트 5개(허용 2, 차단 2, 파싱 실패 1) 작성 후 `bun test`로 통과시키기.
