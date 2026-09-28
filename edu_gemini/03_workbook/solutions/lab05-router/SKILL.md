---
name: meta-router
description: 사용자의 의도를 분석하여 최적의 전문 스킬로 트래픽을 분기하는 메타 관제탑. Use when user request is high-level, ambiguous, or multi-step.
allowed-tools:
  - Skill
---

# 중앙 관제 메타 라우터 (meta-router)

사용자의 한 줄 요청을 분석하여 최적의 스킬로 안내합니다. ("오탐이 미탐보다 싸다")

## 라우팅 매트릭스

| 요청 키워드 / 의도 | 추천 스킬 | 폴백 스킬 |
|---|---|---|
| 버그, 테스트 실패, 에러 | `/investigate` | `/qa` |
| 중복 코드, 리팩토링, 클린업 | `/deslop-shared-libs` | `/review` |
| 배포, PR 생성, 릴리즈 | `/ship` | `/land-and-deploy` |
| 성능 저하, 속도, Core Web Vitals | `/benchmark` | `/canary` |
| 웹 페이지 분석, 스크래핑 | `/scrape` | `/browse` |
