# 12강 [심화]. 스킬을 생성하는 메타 스킬: The Meta-Programming Pattern

**원본:** `gstack/skillify/SKILL.md` (전문 120줄 발췌)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 반복 작업의 영구 자산화

개발자가 터미널이나 브라우저에서 30분에 걸쳐 까다로운 사내 API 호출이나 복잡한 데이터 파이프라인 디버깅을 성공시켰다고 가정해 봅시다.  
다음 주에 똑같은 작업을 하려면 또다시 프롬프트로 장황하게 설명하고 시행착오를 겪어야 할까요?

gstack의 `/skillify`는 **"인간이 성공시킨 단발성 작업을 재사용 가능한 영구 스킬 코드로 자동 변환하는 메타 워크플로"**입니다.

---

## 2. skillify 4단계 파이프라인 (`skillify/SKILL.md` 전문 해부)

```markdown
1: ---
2: name: skillify
3: description: Convert a recent successful browser or terminal workflow into a permanent, reusable skill with deterministic scripts and tests. Run this after completing a complex exploratory task.
4: allowed-tools:
5:   - Bash
6:   - Read
7:   - Write
8:   - Glob
9:   - Grep
10: ---
11: 
12: # Skillify
13: 
14: ## Workflow Phases
15: 
16: ### Phase 1: Session Trace Extraction
17: 1. Inspect the command history and tool calls executed in the current session.
18: 2. Identify the target URL/CLI, selectors, regex, and extraction steps that succeeded.
19: 
20: ### Phase 2: Code & Fixture Generation
21: Generate three core artifacts under `browser-skills/<name>/`:
22: 1. `SKILL.md`: Frontmatter with precise triggers and allowed-tools.
23: 2. `script.ts` (or `script.sh`): Pure deterministic logic isolated from LLM prompt variability.
24: 3. `fixtures/` & `test/`: Saved snapshot and mock unit test.
25: 
26: ### Phase 3: Static & Local Verification
27: Run verification gate before declaring completion:
28: ```bash
29: bun test browser-skills/<name>/
30: bash scripts/validate.sh
31: ```
32: 
33: ### Phase 4: Registration
34: Save to `~/.claude/skills/<name>/` and report slash-command to user.
```

📝 **엔지니어링 통찰: 코드 생성의 완결성**
- 20–25행: 프롬프트 마크다운만 생성하지 않고, **결정적 스크립트(`script.ts`)와 가짜 fixture, 그리고 단위 테스트(`extract.test.ts`)**까지 한 번에 생성합니다.
- 26–31행: 스스로 생성한 스킬을 `validate.sh` 린터로 자가 검증한 뒤에만 사용자에게 등록 완료를 보고합니다.
- 스킬이 스킬을 낳고 검증하는 진정한 메타 프로그래밍의 정수입니다.
