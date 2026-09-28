# Lab 05 [심화 1]: 다중 스킬 관제탑 — `meta-router`

## 🎯 실습 목표
1. 스킬이 수십 개로 늘어났을 때 모델이 적절한 스킬을 놓치는 **스킬 포화(Skill Saturation)** 현상을 해결한다.
2. 사용자의 모호한 요청("버그가 있어", "성능 측정해줘", "코드 정리해줘")을 가로채 최적의 전문 스킬로 트래픽을 분기하는 **메타 라우터(gstack-router 패턴)**를 제작한다.
3. "오탐이 미탐보다 싸다(Aggressive Routing)" 철학을 바탕으로 라우팅 룰 매트릭스를 설계한다.

---

## 📋 과제
`starter/SKILL.md`를 열고 다음 라우팅 테이블을 완성하세요:
1. **Frontmatter**:
   - `name`: `meta-router`
   - `description`: "사용자의 의도를 분석하여 최적의 전문 스킬로 안내하는 메타 관제탑. Use when user request is high-level, ambiguous, or multi-step."
   - `allowed-tools`: `Skill`
2. **본문 라우팅 매트릭스**:
   - 버그/테스트 실패 ➔ `/investigate` (폴백: `/qa`)
   - 중복 코드/정리 ➔ `/deslop-shared-libs` (폴백: `/review`)
   - 배포/PR ➔ `/ship` (폴백: `/land-and-deploy`)
   - 성능/속도 ➔ `/benchmark` (폴백: `/canary`)
