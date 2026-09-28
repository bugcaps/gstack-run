# 01-1. 가장 작은 스킬: `/unfreeze`

**원본:** `gstack/unfreeze/SKILL.md.tmpl` (1–19행), `gstack/unfreeze/SKILL.md` (1–48행, 전체)

## 이 발췌에서 배울 것
1. 스킬 = **YAML frontmatter + 모델에게 주는 Markdown 지시문**이 전부다.
2. 지시문 속 bash 블록은 "모델이 실행할 명령"이지, 자동 실행 스크립트가 아니다.
3. 템플릿(`.tmpl`)과 생성본(`SKILL.md`)의 frontmatter가 **다르다** — 생성기가 손을 댄다.

## 템플릿의 frontmatter (`unfreeze/SKILL.md.tmpl` 1–17행)

```yaml
---
name: unfreeze                  # 📝 슬래시 명령 이름 → /unfreeze
version: 0.1.0
description: |
  Clear the freeze boundary set by /freeze, allowing edits to all directories
  again. Use when you want to widen edit scope without ending the session.
  Use when asked to "unfreeze", "unlock edits", "remove freeze", or
  "allow all edits". (gstack)
# 📝 description = "무엇을 하나" 1문장 + "언제 쓰나(Use when…)" 라우팅 문구
triggers:
  - unfreeze edits
  - unlock all directories
  - remove edit restrictions
allowed-tools:                  # 📝 이 스킬이 쓰는 도구만 명시 (최소 권한)
  - Bash
  - Read
sensitive: true                 # 📝 생성 시 Claude 호스트에서는 제거된다(아래 참고)
---
```

## 생성본 전체 (`unfreeze/SKILL.md` 1–48행)

~~~~markdown
---
name: unfreeze
version: 0.1.0
description: Clear the freeze boundary set by /freeze, allowing edits to all directories again. (gstack)
triggers:
  - unfreeze edits
  - unlock all directories
  - remove edit restrictions
allowed-tools:
  - Bash
  - Read
---
<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->
<!-- Regenerate: bun run gen:skill-docs -->


## When to invoke this skill

Use when you want to widen edit scope without ending the session.
Use when asked to "unfreeze", "unlock edits", "remove freeze", or
"allow all edits".

# /unfreeze — Clear Freeze Boundary

Remove the edit restriction set by `/freeze`, allowing edits to all directories.

```bash
mkdir -p ~/.gstack/analytics
echo '{"skill":"unfreeze","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","repo":"'$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")'"}'  >> ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Clear the boundary

```bash
eval "$(~/.claude/skills/gstack/bin/gstack-paths)"
STATE_DIR="$GSTACK_STATE_ROOT"
if [ -f "$STATE_DIR/freeze-dir.txt" ]; then
  PREV=$(cat "$STATE_DIR/freeze-dir.txt")
  rm -f "$STATE_DIR/freeze-dir.txt"
  echo "Freeze boundary cleared (was: $PREV). Edits are now allowed everywhere."
else
  echo "No freeze boundary was set."
fi
```

Tell the user the result. Note that `/freeze` hooks are still registered for the
session — they will just allow everything since no state file exists. To re-freeze,
run `/freeze` again.
~~~~

### 📝 템플릿 → 생성본에서 바뀐 3가지
| 변화 | 이유 (원본 `scripts/gen-skill-docs.ts` 기준) |
|---|---|
| `description`이 첫 문장만 남고 "Use when…"은 본문 `## When to invoke this skill`로 이동 | **catalog trim**: frontmatter description은 모든 세션에 항상 로드되는 비용이므로 짧게 (258–264행) |
| `sensitive: true` 삭제 | Claude 호스트는 이 필드를 쓰지 않음 (830행 주석 "strip sensitive: field (only Factory uses it)") |
| `AUTO-GENERATED` 헤더 추가 | 생성본을 직접 고치지 말라는 표시 (610행 `GENERATED_HEADER`) |

### 📝 상태는 "파일"로 전달된다
`/unfreeze`는 hook을 끄지 않는다. `freeze-dir.txt`만 지우면 hook이 "경계 없음 → 허용"으로 동작한다(02-hooks/03 참고). **스킬 간 통신 = 공유 상태 파일**이라는 패턴.

## 스킬 제작자를 위한 교훈
- 첫 스킬은 50줄 이하로 시작하라. frontmatter + 목적 한 줄 + 명령 블록 + "사용자에게 결과를 알려라" 한 문장이면 된다.
- 모델에게 **결과 보고 방법까지** 지시하라 ("Tell the user the result").
- 텔레메트리/로그 줄은 `|| true`로 감싸 실패해도 스킬이 멈추지 않게 한다.
- 템플릿 시스템을 쓰면 편집 대상은 **`.tmpl`뿐**이다.

## 직접 해보기
워크북 **[labs/01-first-skill](../../workbook/labs/01-first-skill/)**: `~/.claude/skills/my-first-skill/SKILL.md`를 이 구조로 작성하고 트리거 문구로 호출해 보기.
