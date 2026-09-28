# Lab 04 — 스킬이 많아지고 길어질 때

## 목표
- (a) 여러 스킬이 공유하는 블록을 **템플릿 + 생성기**로 한 곳에서 관리한다.
- (b) 긴 스킬을 **뼈대 + sections**로 쪼개 필요한 부분만 읽게 한다.
- (c) 스킬 형식을 **테스트로 강제**한다.

## 배경
- 발췌본: [05-template-system](../../../excerpts/05-template-system/), [06-progressive-loading](../../../excerpts/06-progressive-loading/), [08-testing-skills](../../../excerpts/08-testing-skills/)
- 원본:
  - `gstack/ARCHITECTURE.md` "SKILL.md template system" 절, `gstack/scripts/gen-skill-docs.ts`, `gstack/scripts/resolvers/`
    — `.tmpl`의 `{{PREAMBLE}}` 등을 생성 시점에 채운다. `investigate`는 .tmpl 268줄 → SKILL.md 704줄.
    생성 파일에는 `<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->`가 들어가고, `--dry-run`은 커밋된 파일과 다르면 exit 1.
  - `gstack/autoplan/SKILL.md` "Section index" 표 + `autoplan/sections/*.md` + `manifest.json`
    — 뼈대(1,032줄)가 "언제 → 어느 파일"을 지정하고, 조건이 안 맞는 섹션은 *"skip the read entirely"*.
  - `gstack/test/skill-validation.test.ts` — frontmatter·트리거 문장 검사

## 단계

### (a) 템플릿 생성기 — `starter/`
구조:
```
starter/
  partials/common.md                      ← 공통 블록 (gstack의 {{PREAMBLE}} 역할)
  src/commit-msg-ko/SKILL.md.tmpl         ← "{{COMMON}}" 한 줄 포함
  src/explain-module/SKILL.md.tmpl
  gen.sh                                  ← TODO 1~5
```
1. `gen.sh`의 TODO를 채운다 (**30줄 이내**).
2. `bash gen.sh` → `out/*/SKILL.md` 확인.
3. `partials/common.md`에 한 줄 추가 → `bash gen.sh --dry-run`이 두 파일 모두 `STALE`로 보고하고 exit 1인지 확인한다.
   이게 CI에서 "템플릿만 고치고 재생성을 깜빡한" 실수를 잡는 방법이다.
4. `out/<name>`을 `~/.claude/skills/<name>`에 복사해 실제로 호출해 본다.

### (b) sections 분할
1. Lab 03에서 만든 `explain-module`(또는 참고 답안)을 뼈대 `SKILL.md` + `sections/*.md`로 나눈다.
2. 뼈대에는 Iron Law, 짧은 초기 단계, **Section index 표**(언제 | 읽을 파일)만 남긴다.
3. 최소 하나는 **조건부** 섹션으로 만든다 (예: "I/O가 보일 때만 risk.md").
4. 두 번 실행해 본다. 조건이 맞지 않는 실행에서는 그 섹션 Read가 **일어나지 않아야** 한다 (도구 호출 로그로 확인).

### (c) 검증기 — `starter/validate.sh`
1. TODO 1~5를 채운다.
2. `bash validate.sh ../fixtures/*/SKILL.md` 실행:

   | fixture | 기대 |
   |---|---|
   | good-skill | OK |
   | long-desc | description 1024자 초과 |
   | no-close | frontmatter 안 닫힘 |
   | no-trigger | "Use when" 없음 |
   | wrong-dir | name 형식 오류 + 폴더명 불일치 |
3. `bash validate.sh out/*/SKILL.md` → 모두 OK.
4. (선택) `gen.sh` 끝에서 `validate.sh`를 불러 생성과 검증을 한 번에 하게 한다.

## 성공 기준
- [ ] `gen.sh`가 30줄 이하이고 `out/`에 `{{`가 하나도 남지 않는다
- [ ] 생성 파일의 frontmatter 바로 뒤에 AUTO-GENERATED 주석이 있다 (첫 줄은 여전히 `---`)
- [ ] 없는 partial(`{{NOPE}}`)이나 인라인 `{{X}}`가 있으면 0이 아닌 코드로 종료한다
- [ ] partial을 고친 뒤 `--dry-run` → exit 1, 재생성 후 → exit 0
- [ ] sections 버전에서 조건부 섹션이 필요 없을 때 읽히지 않는다
- [ ] validate: fixture 5개 판정이 위 표와 같고, 올바른 fixture/출력물은 exit 0

## 막히면
- 1024자 기준: 이 랩에서 정한 상한이다. Claude Code가 description을 매 세션 로드하므로 짧을수록 좋다 (Lab 01 참고).
- `${#desc}`가 한글을 3으로 센다 → `export LC_ALL=C.UTF-8`
- awk에서 `/^---$/`가 안 맞는다 → 템플릿이 CRLF일 수 있다. `sed -i 's/\r$//' src/*/SKILL.md.tmpl`
- partial이 여러 줄인데 첫 줄만 들어간다 → `while ((getline line < f) > 0)` 루프와 `close(f)`
- 섹션 경로는 `~/.claude/skills/<name>/sections/…`처럼 절대경로로 쓰면 안전하다 (autoplan은 스킬 폴더 기준 상대경로를 쓴다).
- 참고 답안: [`solutions/04-scale-up/`](../../solutions/04-scale-up/)
