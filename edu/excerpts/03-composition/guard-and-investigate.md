# 03. 스킬 조합: `/guard`와 `/investigate`의 hook 재사용

**원본:** `gstack/guard/SKILL.md.tmpl` (1–46, 83–86행), `gstack/investigate/SKILL.md.tmpl` (29–39, 116–142행)

## 이 발췌에서 배울 것
1. 새 코드 없이 **기존 스킬의 hook 스크립트를 frontmatter에서 참조**하는 것만으로 새 스킬이 된다.
2. 조합에는 **의존성**이 생긴다 — 필수 의존(guard)과 선택 의존(investigate)을 구분한다.
3. 선택 의존은 "있으면 쓰고, 없으면 건너뛴다"를 코드로 표현한다.

## ① 필수 조합: `/guard` = careful + freeze (`guard/SKILL.md.tmpl` 1–35행)

```yaml
---
name: guard
version: 0.1.0
description: |
  Full safety mode: destructive command warnings + directory-scoped edits.
  Combines /careful (warns before rm -rf, DROP TABLE, force-push, etc.) with
  /freeze (blocks edits outside a specified directory). Use for maximum safety
  when touching prod or debugging live systems. Use when asked to "guard mode",
  "full safety", "lock it down", or "maximum safety". (gstack)
triggers:
  - full safety mode
  - guard against mistakes
  - maximum safety
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/careful/bin/check-careful.sh"
          statusMessage: "Checking for destructive commands..."
    # 📝 ↑ careful의 hook 그대로
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash $HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
    # 📝 ↑ freeze의 hook 그대로. guard 폴더에는 bin/ 이 없다.
sensitive: true
---
```

### 의존성은 문서에 명시 (40–45행)

```markdown
Activates both destructive command warnings and directory-scoped edit restrictions.
This is the combination of `/careful` + `/freeze` in a single command.

**Dependency note:** This skill references hook scripts from the sibling `/careful`
and `/freeze` skill directories. Both must be installed (they are installed together
by the gstack setup script).
```

### 설명도 재사용 (83–86행)

```markdown
## What's protected

See `/careful` for the full list of destructive command patterns and safe exceptions.
See `/freeze` for how edit boundary enforcement works.
```

📝 guard의 Setup(52–75행)은 freeze의 Setup과 사실상 같다 — 질문 문구만 "Guard mode: …"로 다르다. 상태 파일(`freeze-dir.txt`)도 공유하므로 `/unfreeze`가 guard의 편집 경계도 해제한다.

## ② 선택 조합: `/investigate`의 freeze hook (`investigate/SKILL.md.tmpl` 29–39행)

```yaml
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: 'bash -c ''S="$HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"; [ -x "$S" ] && exec bash "$S"; exit 0'''
          statusMessage: "Checking debug scope boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: 'bash -c ''S="$HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"; [ -x "$S" ] && exec bash "$S"; exit 0'''
          statusMessage: "Checking debug scope boundary..."
# 📝 스크립트가 실행 가능하면 exec로 위임, 없으면 exit 0(허용).
# 📝    guard와 달리 freeze가 없어도 investigate는 정상 동작해야 하므로.
# 📝    YAML 작은따옴표 안의 '' 는 작은따옴표 한 글자로 이스케이프된 것.
```

## ③ 본문에서도 가용성 확인 후 분기 (116–142행)

~~~~markdown
## Scope Lock

After forming your root cause hypothesis, lock edits to the affected module to prevent scope creep.

```bash
# $HOME-anchored like the careful/freeze frontmatter hooks (#1871): frontmatter
# hooks and early skill bash run before any runtime var like CLAUDE_SKILL_DIR
# exists, so a ${CLAUDE_SKILL_DIR}-relative path silently never resolves (#2469).
_FREEZE_SCRIPT="$HOME/.claude/skills/gstack/freeze/bin/check-freeze.sh"
[ -x "$_FREEZE_SCRIPT" ] && echo "FREEZE_AVAILABLE" || echo "FREEZE_UNAVAILABLE"
```

**If FREEZE_AVAILABLE:** Identify the narrowest directory containing the affected files. Write it to the freeze state file:

```bash
eval "$(~/.claude/skills/gstack/bin/gstack-paths)"
STATE_DIR="$GSTACK_STATE_ROOT"
mkdir -p "$STATE_DIR"
echo "<detected-directory>/" > "$STATE_DIR/freeze-dir.txt"
echo "Debug scope locked to: <detected-directory>/"
```

# ... (생략: 사용자 안내 문구, 전체 레포 범위 시 생략 조건 — 138–140행) ...

**If FREEZE_UNAVAILABLE:** Skip scope lock. Edits are unrestricted.
~~~~

📝 **센티널 패턴**: bash가 `FREEZE_AVAILABLE`/`FREEZE_UNAVAILABLE`를 출력하고, 모델이 그 출력을 보고 `**If …:**` 분기를 따른다. 사용자 대신 **모델이 경계 디렉터리를 결정**한다는 점이 freeze와 다르다.

## 스킬 제작자를 위한 교훈
- 작은 스킬(부품)을 먼저 만들고, 큰 스킬은 **frontmatter 참조로 조합**하라.
- 필수 의존은 문서에 "Dependency note"로, 선택 의존은 `[ -x "$S" ] && … || exit 0`로.
- 조합 스킬끼리 **상태 파일을 공유**하면 해제 스킬(/unfreeze) 하나로 모두 다룰 수 있다.
- bash 출력 → 모델 분기(센티널)는 스킬에서 조건 로직을 표현하는 가장 단순한 방법이다.

## 직접 해보기
워크북 **[labs/02-hook-guard](../../workbook/labs/02-hook-guard/) 조합 과제** (답안: solutions/02-hook-guard/safe-mode): 랩 2에서 만든 `.env` 보호 hook + careful hook을 묶은 `my-guard` 스킬 만들기.
