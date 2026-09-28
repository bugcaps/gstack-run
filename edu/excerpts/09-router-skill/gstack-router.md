# 09. 라우터 스킬: 62개 스킬의 관제탑 `gstack/SKILL.md`

**원본:** `gstack/SKILL.md` (1–14, 155–184, 186–196, 226–233행)

## 이 발췌에서 배울 것
1. 스킬이 많아지면 **"어느 스킬을 쓸지" 자체를 하나의 스킬**로 만든다 (라우터 패턴).
2. 라우팅 규칙은 "사용자가 이렇게 말하면 → 이 스킬" 형태의 **패턴 → 액션 표**로 쓴다.
3. 오탐(false positive)과 미탐(false negative) 중 **어느 쪽이 더 싼지**를 명시해 모델의 망설임을 없앤다.
4. 자동 호출 여부는 사용자 설정(`PROACTIVE`)으로 존중한다 — User Sovereignty.

## ① frontmatter: 라우터도 평범한 스킬이다 (`gstack/SKILL.md` 1–14행)

```yaml
---
name: gstack
preamble-tier: 1
version: 1.2.0
description: Router for the gstack skill suite. (gstack)
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
triggers:
  - gstack
  - which gstack skill
  - route this with gstack
---
```

📝 description이 한 줄뿐인 이유: 라우터는 "무엇이든 gstack 관련이면 나를 불러라"가 전부다. 상세 조건은 본문의 라우팅 규칙이 담당한다.
📝 `allowed-tools`가 3개뿐 — 라우터는 직접 일하지 않고 **보내기만** 하므로 권한도 최소.

## ② 단 하나의 임무 선언 (`gstack/SKILL.md` 155–167행)

```markdown
## Route first

This is the gstack router. Its one job is to send the request to the right skill.

1. If the request is about a browser, QA, dogfooding, screenshots, or inspecting a page
   (open a site, test a deploy, take a screenshot, check a flow visually) → invoke `/browse`.
# ... (생략: browser 계열 스킬의 Aside 우선/폴백 설명 — 161–166행) ...
2. Otherwise, route by the rules below. If nothing matches, answer directly.
```

📝 "Its one job is …" — 라우터가 직접 문제를 풀기 시작하는 것(스코프 이탈)을 첫 문장에서 차단한다.

## ③ 라우팅 규칙: 사용자 표현 → 스킬 (`gstack/SKILL.md` 185–196행 발췌)

```markdown
**Routing rules — when you see these patterns, INVOKE the skill via the Skill tool:**
- User describes a new idea, asks "is this worth building", brainstorms, pitches a concept → invoke `/office-hours`
- User asks to spec something out, file an issue, write up a ticket, "turn this into a GitHub issue", "backlog item" → invoke `/spec`
# ... (생략: 같은 형태의 규칙 약 35개 — 188–224행) ...
- User reports a bug, error, broken behavior, "why is this broken", "this doesn't work", "wtf", "something's wrong" → invoke `/investigate`
```

📝 각 규칙이 **사용자의 실제 말투**("wtf", "something's wrong")를 인용한다. 1회차에서 배운 "description에 사용자 표현을 넣어라"의 확장판 — 개별 스킬 description에 다 못 넣는 표현을 라우터가 흡수한다.

## ④ 망설임 제거: 오탐이 미탐보다 싸다 (`gstack/SKILL.md` 226–233행)

```markdown
**When in doubt, invoke the skill.** A false positive (invoking a skill that wasn't
needed) is cheaper than a false negative (answering ad-hoc when a structured workflow
exists). The skill provides multi-step workflows, checklists, and quality gates that
always produce better results than an ad-hoc answer. If no skill matches, answer
directly as usual.

If the user opts out of suggestions, run `gstack-config set proactive false`.
If they opt back in, run `gstack-config set proactive true`.
```

📝 모델은 "스킬을 부를까 말까"에서 자주 망설인다. **틀렸을 때의 비용 비교**를 명시하면 결정 규칙이 생긴다.

## ⑤ 사용자 설정 존중 (`gstack/SKILL.md` 176–184행)

```markdown
If `PROACTIVE` is `false`: do NOT proactively invoke or suggest other gstack skills during
this session. Only run skills the user explicitly invokes. This preference persists across
sessions via `gstack-config`.

If `PROACTIVE` is `true` (default): **invoke the Skill tool** when the user's request
matches a skill's purpose. Do NOT answer directly when a skill exists for the task.
```

📝 자동 호출이 싫은 사용자를 위한 영구 스위치. 설정값은 skill-start 스크립트(→ 발췌 11)가 STATUS 라인으로 알려준다.

## 스킬 제작자를 위한 교훈
- 스킬이 5개를 넘고 서로 역할이 겹치기 시작하면 라우터 스킬을 고려하라.
- 라우팅 규칙은 "의도 설명"이 아니라 **사용자가 실제로 칠 문장**으로 써라.
- "애매하면 어떻게 하라"(when in doubt)를 반드시 명시하라 — 비용 비교가 가장 효과적이다.
- 라우터는 일하지 않는다. `allowed-tools` 최소화 + "one job" 선언으로 스코프를 못박아라.

## 직접 해보기 (심화 과제)
랩 1~3에서 만든 스킬 2~3개(commit-msg-ko, protect-secrets, explain-module)를 대상으로 라우터 스킬 `my-router`를 작성해 보자. 각 스킬당 라우팅 규칙 2줄(정식 표현 1개 + 구어체 1개), "when in doubt" 문단 1개를 포함할 것. `claude -p "커밋 메시지 좀"`으로 라우팅이 실제로 일어나는지 확인.
