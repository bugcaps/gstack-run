# Lab 02: 절대 보안 방어선 구축 — `protect-secrets`

## 🎯 실습 목표
1. 도구 실행 직전 OS 쉘에서 입력을 가로채는 `PreToolUse` Hook의 stdin/stdout JSON 프로토콜을 구현한다.
2. 기밀 파일(`.env`, `*.key`, `*.pem`, `id_rsa`)에 대한 도구 접근을 즉시 차단(`deny`)한다.
3. 정규식 우회 버그를 방지하기 위해 진짜 JSON 파서를 사용하고, 파싱 실패 시 차단하는 **fail-closed** 원칙을 구현한다.

---

## 📋 핵심 프로토콜 규격
- **입력 (stdin)**: `{"tool_input": {"file_path": ".env"}}`
- **차단 출력 (stdout)**:
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] 기밀 파일 수정 차단: .env"}}
  ```
- **허용 출력 (stdout)**: `{}` (빈 JSON 객체)
- **종료 코드**: 항상 `exit 0`
- **검증**: `bash test-hook.sh`를 실행하여 통과 여부를 확인하세요.
