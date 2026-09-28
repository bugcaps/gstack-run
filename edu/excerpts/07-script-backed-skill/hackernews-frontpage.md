# 07. 스크립트 기반 스킬: `browser-skills/hackernews-frontpage`

**원본:** `gstack/browser-skills/hackernews-frontpage/` — `SKILL.md` (52줄), `script.ts` (132줄), `script.test.ts` (105줄), `fixtures/hn-2026-04-26.html` (52줄), `_lib/browse-client.ts` (264줄)

## 이 발췌에서 배울 것
1. 매번 같은 결과가 필요한 작업은 **LLM이 즉석에서 하지 말고 결정적 스크립트로** 고정한다.
2. 파싱 로직을 **순수 함수로 분리**하면 네트워크 없이 fixture로 테스트할 수 있다.
3. 스킬 폴더 하나에 SKILL.md + 스크립트 + 테스트 + fixture + SDK 사본까지 담아 **단독으로 이식 가능**하게 만든다.

## 폴더 구조

```
hackernews-frontpage/
├── SKILL.md                    # 📝 트리거 + 사용법 + 동작 설명
├── script.ts                   # 📝 실행 진입점 + 순수 파서 export
├── script.test.ts              # 📝 fixture 기반 단위 테스트
├── fixtures/hn-2026-04-26.html # 📝 실제 구조를 본뜬 5개 스토리 HTML
└── _lib/browse-client.ts       # 📝 브라우저 데몬 SDK의 "스킬별 사본"
```

## ① SKILL.md frontmatter (1–14행)

```yaml
---
name: hackernews-frontpage
description: Scrape the Hacker News front page (titles, points, comment counts).
host: news.ycombinator.com
# 📝 이 스킬이 다루는 사이트
trusted: true
source: human
# 📝 사람이 작성(↔ /skillify가 생성한 스킬)
version: 1.0.0
args: []
triggers:
  - scrape hacker news frontpage
  - scrape hn frontpage
  - get hn top stories
  - latest hacker news stories
---
```

📝 이것은 일반 Claude Code 스킬이 아니라 gstack 브라우저(`$B skill run …`)가 실행하는 **browser-skill** 형식이다. `host`, `trusted`, `source`, `args` 필드는 이 형식 전용이다. 그래도 "frontmatter + 스크립트 + 테스트" 패턴은 일반 스킬에 그대로 적용된다.

### 존재 이유를 문서에 명시 (43–52행)

```markdown
## Why this is the reference skill

`hackernews-frontpage` is the smallest interesting browser-skill: no auth,
stable HTML, deterministic output, file-fixture-friendly. # ... (생략 — 46–49행) ...

When the HN HTML rotates and our selectors break, the test fails against the
captured fixture before users notice. That's the point.
```

## ② script.ts: 출력 계약과 순수 함수 분리 (1–34, 53–58, 72–82, 120–132행)

```ts
/**
 * hackernews-frontpage — scrape the HN front page and emit JSON.
 *
 * Output protocol:
 *   stdout = a single JSON document on success: { stories: Story[], count }
 *   stderr = anything we want logged (currently nothing)
 *   exit 0 on success, nonzero on parse / network failure.
 *
 * The parser logic (`parseStoriesFromHtml`) is exported so script.test.ts can
 * exercise it against bundled HTML fixtures without spinning up the daemon.
 */
// 📝 출력 프로토콜(stdout=JSON 1개, exit code)을 맨 위에 명시 → 호출하는 모델이 파싱하기 쉬움

import { browse } from './_lib/browse-client';

export interface Story {
  /** 1-based rank as displayed on HN. */
  rank: number;
  /** HN item id (the integer in `tr.athing[id]`). */
  id: string;
  title: string;
  /** Outbound URL the title links to. */
  url: string;
  /** null when the row has no score (job postings). */
  points: number | null;
  /** null when the row has no comments link (job postings). */
  comments: number | null;
}
// ... (생략: Output 타입, URL 상수, 구조 설명 주석 — 29–52행) ...

export function parseStoriesFromHtml(html: string): Story[] {
  const stories: Story[] = [];

  // Match each `tr.athing` row, capturing the id attribute and the row body.
  const rowRegex = /<tr\s+[^>]*\bclass="athing[^"]*"[^>]*\bid="(\d+)"[^>]*>([\s\S]*?)<\/tr>/g;
  // ... (생략: 제목·URL 추출 — 59–71행) ...

    // The next sibling tr should hold the subtext row. Bound the lookahead
    // to before the next story (tr.spacer marks the gap, then tr.athing).
    // Bug if we don't bound: the score from story N+1 leaks into story N
    // when story N is a job posting (no score of its own).
    // 📝 fixture에 "점수 없는 채용 공고" 행을 넣어 이 버그를 테스트로 고정했다(③ 참고)
  // ... (생략: 경계 계산, 점수/댓글 파싱, 엔티티 디코딩 — 76–118행) ...

// ─── Main entry (only when run as a script, not when imported by tests) ─

if (import.meta.main) {
  await main();
}

async function main(): Promise<void> {
  await browse.goto(FRONT_PAGE_URL);
  const html = await browse.html();
  const stories = parseStoriesFromHtml(html);
  const output: Output = { stories, count: stories.length };
  process.stdout.write(JSON.stringify(output) + '\n');
}
// 📝 I/O(브라우저)는 main에만, 로직은 순수 함수에. import.meta.main 가드로 테스트 import 시 실행 안 됨.
```

## ③ script.test.ts: 네트워크 없는 테스트 (1–21, 65–89행)

```ts
/**
 * hackernews-frontpage script tests — exercise parseStoriesFromHtml against
 * the bundled HN fixture. No daemon, no network: the parser is a pure function
 * over HTML, so we test it directly.
 */

import { describe, it, expect } from 'bun:test';
import * as fs from 'fs';
import * as path from 'path';
import { parseStoriesFromHtml } from './script';

const FIXTURE = fs.readFileSync(
  path.join(__dirname, 'fixtures', 'hn-2026-04-26.html'),
  'utf-8',
);

describe('parseStoriesFromHtml against bundled HN fixture', () => {
  it('returns 5 stories (matching the fixture)', () => {
    const stories = parseStoriesFromHtml(FIXTURE);
    expect(stories).toHaveLength(5);
  });
  // ... (생략: 순위·id·제목·URL·점수·댓글 테스트 — 23–63행) ...

  it('treats "discuss" links as 0 comments', () => {
    const stories = parseStoriesFromHtml(FIXTURE);
    expect(stories[3].comments).toBe(0);
  });

  it('returns null points + null comments for job postings', () => {
    const stories = parseStoriesFromHtml(FIXTURE);
    // Story #3 is the YC-hiring row in the fixture.
    expect(stories[2].title).toContain('YC W26');
    expect(stories[2].points).toBeNull();
    expect(stories[2].comments).toBeNull();
  });

  it('returns [] for empty HTML', () => {
    expect(parseStoriesFromHtml('')).toEqual([]);
  });

  it('returns [] for HTML with no story rows', () => {
    expect(parseStoriesFromHtml('<html><body><p>nothing here</p></body></html>')).toEqual([]);
  });

  it('does not fabricate stories from arbitrary tr.athing rows missing titleline', () => {
    const html = '<tr class="athing" id="999"><td>nothing</td></tr>';
    expect(parseStoriesFromHtml(html)).toEqual([]);
  });
  // 📝 "없는 데이터를 지어내지 않는다"를 테스트로 명시
});
```

## ④ SDK를 스킬마다 복사하는 이유 (`_lib/browse-client.ts` 1–15행)

```ts
/**
 * browse-client — canonical SDK that browser-skill scripts import to drive the
 * gstack daemon over loopback HTTP.
 *
 * Distribution model:
 *   This file is the canonical source. Each browser-skill ships a sibling
 *   copy at `<skill>/_lib/browse-client.ts` (Phase 2's generator copies it
 *   alongside every generated skill; Phase 1's bundled `hackernews-frontpage`
 *   reference skill ships a hand-copied version). The skill imports the
 *   sibling via relative path: `import { browse } from './_lib/browse-client'`.
 *
 *   Why per-skill copies and not a single global SDK: each skill is fully
 *   portable (copy the directory anywhere, it runs), version drift is
 *   impossible (the SDK is frozen at the version the skill was authored
 *   against), no npm publish workflow, no fixed-path tilde imports.
 */
```

📝 02-hooks의 "복사본은 drift를 만든다 → 공용 파일 1개"와 **반대 결정**이다. 차이는 목적: hook 헬퍼는 **항상 최신 수정이 퍼져야** 하고, 스킬 SDK는 **작성 시점 버전에 고정되어야** 한다. 트레이드오프를 설명하기 좋은 대비.

## 스킬 제작자를 위한 교훈
- 반복·정확성이 중요한 부분은 **스크립트**, 판단이 필요한 부분은 **프롬프트**로 나눠라.
- 스크립트 출력은 "stdout = JSON 하나, exit code로 성공 여부" 같은 **계약**을 문서화하라.
- I/O와 로직을 분리하고, 실제 페이지를 본뜬 **fixture**로 엣지 케이스(채용 공고, 빈 입력)를 고정하라.
- 스킬 폴더는 복사만으로 동작하도록 **자급자족**하게. 공유 vs 복사는 목적에 따라 고른다.

## 직접 해보기
**심화 과제** (워크북에 랩과 답안 없음): 로그 파일에서 에러를 집계하는 `script.ts`(순수 함수 export) + fixture + 테스트 3개를 가진 스킬 만들기.
