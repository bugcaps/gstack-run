# 06강. 결정적 워커와 Fixture 테스트: The Deterministic Worker Pattern

**원본:** `gstack/browser-skills/hackernews-frontpage/` (`SKILL.md`, `script.ts`, `fixtures/`)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. LLM에게 시키지 말아야 할 작업들

에이전트에게 "웹 페이지 열어서 1등부터 30등까지 뉴스 제목이랑 링크 다 긁어서 JSON으로 만들어줘"라고 프롬프트로만 시키면 어떤 일이 생길까요?
1. 중간 순위 3~4개를 건너뛰어 누락합니다.
2. 링크 URL을 제멋대로 완성하거나 환각(Hallucination)합니다.
3. 2,000토큰 이상의 생성 비용이 발생합니다.

---

## 2. 해결책: 결정적 스크립트 오프로딩 (The Worker Pattern)

gstack의 `browser-skills`는 역할을 명확히 쪼갭니다:

```
[사용자 요청] ──▶ [LLM: 의도 파악] ──▶ [script.ts: 100% 결정적 데이터 파싱]
                                                        │ (JSON 출력)
[사용자 보고] ◀── [LLM: 결과 해석 & 브리핑] ◀──────────────┘
```

### `browser-skills/hackernews-frontpage/` 디렉토리 구조:
```text
hackernews-frontpage/
├── SKILL.md            # LLM용 라우팅 & 브리핑 가이드
├── script.ts           # Cheerio/Playwright 기반 순수 TS 추출 로직 (0.05초 실행)
├── test/
│   └── extract.test.ts # 순수 단위 테스트
└── fixtures/
    └── hn-sample.html  # 저장된 실제 웹페이지 HTML 목업
```

### `script.ts` 핵심 발췌:
```typescript
// script.ts
import { load } from "cheerio";
const html = await fetchHN();
const $ = load(html);
const stories = [];
$(".athing").each((i, el) => {
  stories.push({
    rank: i + 1,
    title: $(el).find(".titleline > a").text(),
    url: $(el).find(".titleline > a").attr("href")
  });
});
console.log(JSON.stringify(stories));
```

📝 **엔지니어링 의의**:
- 데이터 추출은 정규식과 DOM 셀렉터로 **결정적(Deterministic)**으로 끝냅니다.
- `fixtures/hn-sample.html`을 대상으로 `bun test`를 돌려, LLM API 호출 없이도 CI에서 100% 무료로 파싱 회귀 테스트를 수행합니다.
- LLM은 스크립트가 뱉어낸 무결점 JSON을 읽고 "오늘의 주요 뉴스 요약"이라는 **고차원 인지 작업**에만 리소스를 집중합니다.
