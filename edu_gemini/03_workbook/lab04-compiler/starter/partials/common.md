## Common Safeguards (공통 보안 규칙)
- 기밀 파일(`.env`, `credentials.json`, `*.pem`)은 절대 외부에 노출하거나 커밋하지 않는다.
- 파멸적 명령(`rm -rf /`, `DROP TABLE`) 실행 전 반드시 사용자 승인을 묻는다.
