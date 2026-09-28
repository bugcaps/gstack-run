---
name: decision-memory
description: 중요한 기술적 결정과 아키텍처 변경 사유를 불변 로그에 영구 기록한다. Use when user makes an architectural decision, chooses a library, or resolves a tricky bug.
allowed-tools:
  - Bash
  - Read
---

# 세션 간 불변 결정 메모리 (decision-memory)

세션 종료 후 기억 상실을 방어하기 위해 아키텍처적 결정을 `.claude/decisions.jsonl`에 기록합니다.

## 실행
```bash
bash record-decision.sh "<스킬명>" "<결정내용>" "<선택이유(WHY)>"
```
검색: `grep -i "keyword" .claude/decisions.jsonl`
