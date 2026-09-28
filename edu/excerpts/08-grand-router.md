# 08강 [심화]. 62개 스킬의 관제탑: The Traffic Controller Pattern

**원본:** `gstack/gstack-router/SKILL.md` (전문 95줄 발췌)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 스킬 포화(Skill Saturation) 문제

스킬이 10개 내외일 때는 모델이 사용자 의도에 맞는 스킬을 잘 찾아냅니다. 하지만 스킬이 50개, 60개를 넘어가면:
1. **의도 혼란 (Routing Ambiguity)**: "코드 좀 봐줘"라고 했을 때 `/review`로 갈지, `/investigate`로 갈지, `/deslop-shared-libs`로 갈지 모델이 갈팡질팡합니다.
2. **미탐(False Negative) 증가**: 적절한 스킬이 존재함에도 불구하고 평범한 일반 챗으로 대답해 버립니다.

---

## 2. 관제탑 메타 라우터 (`gstack-router/SKILL.md`) 해부

gstack은 62개 스킬 위에 **스킬을 라우팅하는 스킬**을 두었습니다:

```markdown
1: ---
2: name: gstack-router
3: description: Central dispatcher that routes user intent to the best gstack skill. Evaluates ambiguous or high-level requests.
4: allowed-tools:
5:   - Skill
6: ---
7: 
8: # Routing Rules Table
9: 
10: When a user makes an exploratory request, match against these families:
11: 
12: | Trigger keywords               | Primary Skill     | Fallback Skill |
13: |--------------------------------|-------------------|----------------|
14: | "bug", "broken", "failing test" | /investigate      | /qa            |
15: | "clean up", "duplication", "DRY"| /deslop-shared-libs| /review       |
16: | "ship", "merge", "pull request" | /ship             | /land-and-deploy|
17: | "slow", "performance", "CWV"   | /benchmark        | /canary        |
18: | "look at this URL", "scrape"   | /scrape           | /browse        |
```

📝 **엔지니어링 철학: "오탐이 미탐보다 싸다"**
- gstack 라우터의 핵심 철학은 **"Aggressive Routing"**입니다.
- 사용자가 스킬 이름을 몰라도, 사용자의 발화에서 힌트를 포착하면 적극적으로 스킬을 추천합니다.
- 잘못된 스킬을 추천했을 때 사용자가 거절하는 비용보다, 스킬이 있는 줄도 모르고 삽질하는 비용(미탐)이 훨씬 크기 때문입니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab05-router](../../03_workbook/lab05-router/)**: 다중 스킬 간 키워드 충돌을 해결하고 최적의 스킬로 안내하는 `meta-router`를 직접 제작합니다.
