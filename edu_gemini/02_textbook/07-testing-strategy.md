# 07강. 스킬 테스트 전략과 품질 게이트: The Quality Gate Pattern

**원본:** `gstack/scripts/validate.sh` (전문 90줄), `gstack/CLAUDE.md` (Testing Internals)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 스킬 품질 테스트의 경제학

스킬을 만들고 배포하기 전, 정상 동작을 어떻게 검증할까요?
- **방법 A: 매번 LLM API를 호출하며 테스트 (`claude -p`)**
  - 비용: 1회 테스트당 수 달러, 수십 초~수분 소요.
  - 결과: 테스트가 너무 느리고 비싸서 개발자가 테스트를 건너뛰게 됨.
- **방법 B: 2단계 품질 게이트 (The Two-Tier Gate)**
  - 1차: 비용 0원, 0.1초 소요의 **정적 린터 (`validate.sh`)**로 결함의 95% 적발.
  - 2차: 정적 검증을 통과한 스킬에 한해 선별적으로 **LLM 리허설** 수행.

---

## 2. 정적 린터 소스코드 해부 (`scripts/validate.sh`)

```bash
1: #!/usr/bin/env bash
2: # scripts/validate.sh — free deterministic checks on all skills
3: set -euo pipefail
4: 
5: ERRS=0
6: for skill in ~/.claude/skills/*/SKILL.md; do
7:   name=$(basename $(dirname "$skill"))
8:   
9:   # 1. Frontmatter 닫힘 태그 검사
10:   if [ $(grep -c "^---" "$skill") -lt 2 ]; then
11:     echo "FAIL: $name has unclosed frontmatter"
12:     ERRS=$((ERRS + 1))
13:   fi
14: 
15:   # 2. 카탈로그 예산 (250자 하드 리밋) 검사
16:   desc_len=$(sed -n '/^description:/,/^[a-z]/p' "$skill" | wc -c)
17:   if [ "$desc_len" -gt 250 ]; then
18:     echo "FAIL: $name description too long ($desc_len > 250 chars)"
19:     ERRS=$((ERRS + 1))
20:   fi
21: 
22:   # 3. 트리거(Use when) 키워드 존재 검사
23:   if ! grep -qi "Use when" "$skill"; then
24:     echo "FAIL: $name missing 'Use when' routing trigger"
25:     ERRS=$((ERRS + 1))
26:   fi
27: done
28: exit $ERRS
```

📝 **해설**:
- 16–20행: description 길이를 250자(약 40~50단어)로 엄격히 제한합니다. 한 스킬이 장황한 설명을 쓰면 60개 스킬의 카탈로그 전체가 비대해지기 때문입니다.
- 22–26행: `Use when` 트리거 키워드가 없으면 빌드 자체가 실패합니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab04-compiler](../../03_workbook/lab04-compiler/)**: `validate.sh` 정적 린터를 직접 작성하고, 고의로 결함을 심어둔 픽스처들을 100% 잡아내는지 검증합니다.
