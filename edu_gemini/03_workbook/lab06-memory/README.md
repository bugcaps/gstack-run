# Lab 06 [심화 2]: 세션 불변 결정 메모리 — `decision-memory`

## 🎯 실습 목표
1. 모든 LLM 세션이 종료 후 기억을 잃어버리는 **세션 무상태성(Amnesia)** 문제를 해결한다.
2. 중요한 기술적 결정과 탈락시킨 대안을 불변 추가 전용(Append-only) 파일인 `decisions.jsonl`에 기록하는 스크립트를 구현한다.
3. 다음 세션의 에이전트가 `grep`만으로 0.001초 만에 과거 결정을 검색하여 계승하도록 파이프라인을 구축한다.

---

## 📋 과제
`starter/record-decision.sh`를 완성하세요:
- 입력: `[스킬명] [결정사항] [이유(WHY)]`
- 동작:
  1. 현재 UTC 타임스탬프 생성
  2. 따옴표 이스케이프 처리
  3. `.claude/decisions.jsonl`에 1줄 JSON 객체로 안전하게 추가 (Append)
- 조회 커맨드: `grep -i "키워드" .claude/decisions.jsonl`
