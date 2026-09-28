# 강사용 3분 라이브 데모 시나리오 & 치트시트 (Live Demo Guide)

> **강사 가이드**:
> 백 마디 설명보다 터미널에서 한 번 보여주는 것이 10배 강력합니다.  
> 본 문서의 데모들은 강의 도중 1~2분 안에 강사의 터미널에서 즉시 실행해 보여줄 수 있도록 구성되어 있습니다.  
> 모든 명령어는 원클릭 실행이 가능하도록 사전에 검증되었습니다.

---

## 🎬 데모 1. 라우팅의 기적: 단어 하나로 스킬이 무시되는 순간
- **시연 타이밍**: **Slide 06** (호출되는 description과 안 되는 description) 직후
- **소요 시간**: 1분 30초
- **핵심 메시지**: "본문이 아무리 좋아도, description에 언제(When) 쓸지 안 적으면 모델은 거들떠보지도 않는다."

### 실행 절차 (Git Bash):
```bash
# 1. 데모 폴더로 이동
cd /d/01_aistudy/gstack_run/edu/instructor/demo/demo1-routing

# 2. 임시 git 저장소 및 파일 준비 (한 줄 실행)
bash setup.sh

# 3. 모델에게 요청해보기 (좋은 description의 commit-msg-ko 등록 상태)
claude -p "커밋 메시지 써줘" --allowedTools "Skill" "Read" "Bash(git diff:*)"
```
- **청중에게 보여줄 관전 포인트**:
  - 모델이 프롬프트에서 `commit-msg-ko`라는 단어를 듣지 못했음에도, 스스로 `Skill("commit-msg-ko")`를 호출하는 장면을 화면에서 지목.
  - "이게 바로 자연어 라우팅입니다. 모델은 description의 `Use when asked to '커밋 메시지 써줘'`라는 문구를 보고 스스로 판단했습니다."

---

## 🎬 데모 2. 절대 뚫리지 않는 하드 가드: Hook의 실시간 차단
- **시연 타이밍**: **Slide 11~12** (Hook과 위험도 판정) 직후
- **소요 시간**: 1분 30초
- **핵심 메시지**: "프롬프트로 백날 부탁해 봤자 소용없다. 훅 스크립트가 0.01초 만에 물리적으로 쳐낸다."

### 실행 절차 (Git Bash):
```bash
# 1. 훅 스크립트에 .env 파일 쓰기 시뮬레이션 payload 직접 주입
printf '{"tool_input":{"file_path":".env"}}' | bash /d/01_aistudy/gstack_run/edu/workbook/solutions/02-hook-guard/protect-secrets/bin/check-secrets.sh
```
- **출력 결과 (화면에 하이라이트)**:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[protect-secrets] 비밀 파일 수정 차단: .env"}}
```

```bash
# 2. 이번엔 일반 파일(src/index.js) 시뮬레이션
printf '{"tool_input":{"file_path":"src/index.js"}}' | bash /d/01_aistudy/gstack_run/edu/workbook/solutions/02-hook-guard/protect-secrets/bin/check-secrets.sh
```
- **출력 결과**:
```json
{}
```
- **청중에게 보여줄 관전 포인트**:
  - ".env가 들어오는 순간 훅이 즉시 `permissionDecision: deny`를 꽂아버립니다. 모델은 도구를 쓰지도 못하고 거절당합니다."
  - "반면 정상 파일은 빈 객체 `{}`를 반환하여 0초 만에 무저항 통과합니다."

---

## 🎬 데모 3. 0.1초 만에 끝나는 스킬 빌드 & 정적 검증
- **시연 타이밍**: **Slide 19 & 22** (템플릿 치환 및 95% 정적 테스트) 직후
- **소요 시간**: 1분
- **핵심 메시지**: "스킬을 LLM API로 테스트하지 마라. 무료 정적 린트로 0.1초 만에 잡아내라."

### 실행 절차 (Git Bash):
```bash
# 1. 템플릿 컴파일 실행
cd /d/01_aistudy/gstack_run/edu/workbook/solutions/04-scale-up
bash gen.sh

# 2. 정적 린트 실행 (통과 케이스)
bash validate.sh
```
- **청중에게 보여줄 관전 포인트**:
  - 수백 줄의 템플릿이 0.05초 만에 완전한 `SKILL.md`로 컴파일되는 속도.
  - "빌드 완료 후 `validate.sh`가 YAML 문법, 글자 수 제한, 파일 경로 무결성을 1초도 안 되어 전수 검사합니다. 이것이 gstack의 엔지니어링 표준입니다."
