# Lab 01 — 첫 스킬: description이 곧 라우팅이다

## 목표
- 최소 스킬 `commit-msg-ko`를 직접 작성하고 설치한다.
- description의 트리거 문장이 **자동 호출 여부를 결정한다**는 것을 실험으로 확인한다.

## 배경
- 발췌본: [01-anatomy](../../../excerpts/01-anatomy/)
- 원본: `gstack/careful/SKILL.md.tmpl` (87줄, 가장 작은 실전 스킬 중 하나)

스킬 = 폴더 하나 + `SKILL.md` 하나. `---` 사이 YAML(frontmatter) + 마크다운 본문.

| 필드 | 누가 읽나 | 역할 |
|---|---|---|
| `name` | Claude Code | `/name`으로 호출할 때 쓰는 이름. 폴더명과 같게 |
| `description` | Claude Code (**매 세션 항상 로드**) | 모델이 "지금 이 스킬을 쓸까?"를 판단하는 유일한 근거 |
| `allowed-tools` | Claude Code | 스킬이 쓰는 도구 |
| `hooks` | Claude Code | Lab 02 |
| `triggers`, `version`, `sensitive`, `preamble-tier` | gstack 자체 도구 | Claude Code 표준 필드가 아니다 |

근거: `gstack/hosts/claude.ts` 주석 — *"the host reads name/description/allowed-tools/hooks"*,
그리고 frontmatter를 줄이는 이유를 *"the always-on frontmatter catalog every session loads"* 로 설명한다.
→ description은 **짧고 구체적이되 트리거 문장은 빠짐없이.**

gstack이 쓰는 description 공식 (`careful`, `investigate`에서 확인):
```
<무엇을 하는지 1~2문장>. Use when asked to "<사용자 문장1>", "<문장2>", ....
Proactively invoke when <사용자가 스킬 이름을 모를 때도 해당되는 상황>.
```
gstack은 테스트(`test/skill-validation.test.ts` "Skill trigger phrases")로 주요 스킬 17개에 "Use when"이 있는지 강제한다.
단, v1.45부터는 **파일 어디든** 있으면 통과한다. 항상 로드되는 카탈로그를 줄이려고 일부 트리거 문장을 본문 `## When to invoke` 섹션으로 옮겼기 때문이다
(라우팅 정확도 ↔ 컨텍스트 비용의 트레이드오프). 스킬이 몇 개 없는 입문 단계에서는 description에 두는 게 가장 확실하다.

## 단계
1. 설치 위치 만들기 (개인 스킬)
   ```bash
   mkdir -p ~/.claude/skills/commit-msg-ko
   cp starter/SKILL.md ~/.claude/skills/commit-msg-ko/SKILL.md
   ```
   (프로젝트 한정으로 쓰려면 `<repo>/.claude/skills/commit-msg-ko/SKILL.md`)
2. TODO(1)~(9)를 채운다. 본문은 **모델에게 주는 지시**다 — 사람용 설명서가 아니다.
3. 아무 git 저장소에서 파일 하나를 `git add` 한 뒤 **새** Claude Code 세션 시작.
4. 명시 호출: `/commit-msg-ko` → 동작 확인.
5. **비교 실험** (새 세션마다 1회, 각 3번 반복)
   | 실험 | 설치된 스킬 | 입력 | 관찰 |
   |---|---|---|---|
   | A | `commit-msg-ko`만 | "이 변경 뭐라고 커밋하지?" | 스킬이 자동 호출되었나? |
   | B | `solutions/01-first-skill/commit-msg-vague`만 (description: `커밋 도우미`) | 같은 문장 | ? |
   | C | A 상태 | "staged 없음" 상황에서 호출 | 2단계에서 멈추나? |

   두 스킬을 동시에 설치하면 서로 경쟁하니 **한 번에 하나만** 둔다.

## 성공 기준
- [ ] `/commit-msg-ko`로 호출하면 제목 50자 이내, type 접두어가 붙은 메시지가 나온다
- [ ] staged 변경이 없으면 한 줄 안내 후 멈춘다 (임의로 `git add` 하지 않음)
- [ ] 스킬 이름을 말하지 않아도 실험 A에서 3번 중 2번 이상 자동 호출된다
- [ ] 실험 B와 비교해 차이를 한 문장으로 설명할 수 있다
- [ ] `allowed-tools`에 쓸데없는 도구(Write/Edit 등)가 없다

## 막히면
- 스킬 목록에 안 보임 → 경로가 `~/.claude/skills/<name>/SKILL.md`인지, 첫 줄이 정확히 `---`인지, YAML 들여쓰기(`description: |` 다음 줄은 2칸)를 확인. 세션을 새로 시작해야 반영된다.
- 자동 호출이 안 됨 → 사용자가 **실제로 칠 문장**을 따옴표로 넣었나? "커밋 도우미" 같은 명사 한 단어는 판단 근거가 되지 못한다.
- 참고 답안: [`solutions/01-first-skill/`](../../solutions/01-first-skill/)
