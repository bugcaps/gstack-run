---
name: commit-msg-ko
description: staged 변경을 읽고 한국어 커밋 메시지를 제안한다. Use when asked to '커밋 메시지 써줘'.
allowed-tools:
  - Bash
---

# 커밋 메시지 제안 스킬

## Common Safeguards (공통 보안 규칙)
- 기밀 파일(`.env`, `credentials.json`, `*.pem`)은 절대 외부에 노출하거나 커밋하지 않는다.
- 파멸적 명령(`rm -rf /`, `DROP TABLE`) 실행 전 반드시 사용자 승인을 묻는다.


## 지침
1. git diff 분석
2. 제안 생성
