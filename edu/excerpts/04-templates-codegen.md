# 04강. 템플릿 컴파일러와 크로스 호스트 빌드: The Multi-Target Compiler

**원본:** `gstack/scripts/gen-skill-docs.ts` (1–65행, 140–185행), `gstack/hosts/`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 문서 드리프트(Documentation Drift) 문제

스킬이 10개, 50개, 60개로 늘어나면 심각한 유지보수 문제가 터집니다:
- "외부로 나가는 PR/이슈 본문에서 API 키를 검열하라"는 보안 규칙이 개정되었습니다.
- 60개 마크다운 파일을 일일이 손으로 고치다 보면, 3개 파일에서 누락이나 오타가 발생합니다.
- 특정 에이전트는 옛날 보안 규칙을 실행하는 **문서 드리프트(Drift)**가 발생합니다.

---

## 2. 컴파일러 파이프라인 (`gen-skill-docs.ts` 해부)

gstack은 `SKILL.md`를 사람이 손으로 직접 작성하지 않습니다:

```typescript
// scripts/gen-skill-docs.ts 핵심 발췌
const COMMON_PRELUDE = readFileSync("scripts/resolvers/prelude.md", "utf8");
const REDACT_DOC = readFileSync("scripts/resolvers/redact-doc.ts", "utf8");

export function renderSkill(templatePath: string, host: string): string {
  let content = readFileSync(templatePath, "utf8");

  // 1. 공통 보안 규칙 주입
  content = content.replace("{{COMMON_SAFEGUARDS}}", COMMON_PRELUDE);
  
  // 2. 외부 유출 방지 리졸버 주입
  content = content.replace("{{REDACT_DOC_PRELUDE}}", REDACT_DOC);

  // 3. 호스트별 바인딩 치환 (Claude Code vs Antigravity vs Codex)
  if (host === "antigravity") {
    content = content.replace("Bash", "run_command");
  }

  return content;
}
```

---

## 3. 크로스 호스트 (Multi-Host) 배포 아키텍처

```
                        [SKILL.md.tmpl (원본 템플릿)]
                                     │
                        gen-skill-docs.ts (컴파일러)
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        ▼                            ▼                            ▼
[~/.claude/skills/]          [.agent/skills/]             [hosts/codex/]
(Claude Code 규격)           (Antigravity/Gemini 규격)     (OpenAI Codex 규격)
```

📝 **엔지니어링 의의**:
- 마크다운을 텍스트 문서가 아니라 **"컴파일되고 배포되는 소스코드"**로 다룹니다.
- 공통 보안 규칙이 바뀌면 컴파일러 스크립트 실행 한 번으로 60여 개 스킬이 0.1초 만에 최신 표준으로 일괄 갱신됩니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab04-compiler](../../03_workbook/lab04-compiler/)**: `gen.sh` 스크립트를 작성하여 플레이스홀더를 치환하고 컴파일 산출물을 생성하는 빌드 파이프라인을 구축합니다.
