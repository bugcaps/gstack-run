# gstack 엔지니어링 마스터: 4대 실전 라이브 시연 가이드 (LIVE-DEMO.md)

> **강사용 가이드**: 본 문서는 강의 도중 수강생들의 몰입도를 극대화하고 이론의 신뢰성을 입증하기 위해, 강사가 1~3분 내에 무대에서 직접 실행하여 보여주는 **4대 라이브 시연 매뉴얼**입니다.  
> 각 시연마다 **사전 준비 커맨드**, **실제 타이핑 커맨드**, **청중이 보는 터미널 화면**, **강사의 타이밍별 해설 대본**, 그리고 **시연 장애 발생 시 10초 복구 플랜 B**를 포함합니다.

---

## 📋 시연 퀵 매트릭스

| 데모 | 슬라이드 연계 | 시연 주제 | 소요 시간 | 핵심 시각 충격 |
|------|-------------|-----------|----------|----------------|
| **Demo 1** | Slide 06 (1회차) | 자연어 라우팅: 모호한 설명 vs 트리거 설명 충돌 | 2분 | 모호한 설명은 무시되고 트리거 스킬만 100% 호출되는 장면 |
| **Demo 2** | Slide 11, 12 (2회차) | 물리 보안: 탈옥 프롬프트 vs PreToolUse Hook 차단 | 3분 | `rm -rf` 및 `.env` 접근 시 OS 커널 도달 전 물리 차단 |
| **Demo 3** | Slide 23 (4회차) | 점진적 로딩: 1,500줄 모놀리스 vs 200줄 분할 토큰 측정 | 2분 | 컨텍스트 토큰이 1,840개에서 210개로 88% 급감하는 숫자 |
| **Demo 4** | Slide 35 (6회차 심화) | 결정 메모리: 세션 리셋 후에도 아키텍처 결정 보존 | 3분 | `/clear` 후에도 `decisions.jsonl`을 읽고 결정 드리프트 방지 |

---

## 🎬 Demo 1: 자연어 라우팅 대조 시연 (Routing Collision & Resolution)

### 1. 시연 목적 & 아키텍처 포인트
- LLM 에이전트가 스킬을 선택할 때, 문학적/장황한 설명은 무시되고 **[명시적 트리거 단어]**와 **[따옴표 구문]**이 포함된 스킬만이 호출된다는 사실을 실시간으로 증명합니다.

### 2. 사전 준비 (Setup)
강의 시작 전 또는 쉬는 시간에 터미널에서 다음 명령을 실행하여 테스트 환경을 준비합니다:
```bash
# 실습 디렉토리로 이동
cd D:/01_aistudy/gstack_run/edu_gemini/03_workbook/lab01-routing

# 두 가지 스킬 준비 확인
# 1) bad-skill: 모호한 설명
# 2) solutions/commit-msg-ko: 정밀한 트리거 설명
```

### 3. 실시간 실행 스텝 (Live Execution)
1. **모호한 스킬의 description을 수강생에게 보여줍니다**:
   ```bash
   cat << 'EOF'
   description: 이 스킬은 깃 커밋 메시지를 작성하기 위해 심층 분석을 수행하며
     변경 사항을 파악하고 최적의 메시지를 도출합니다.
   EOF
   ```

2. **gstack 스타일의 description을 나란히 보여줍니다**:
   ```bash
   cat << 'EOF'
   description: staged 변경을 읽고 한국어 커밋 메시지를 제안한다. Use when asked
     to '커밋 메시지 써줘', '커밋 메시지 만들어줘', 'write commit msg'.
   EOF
   ```

3. **시뮬레이션 테스트 러너 실행**:
   ```bash
   bash test_lab01.sh
   ```

### 4. 청중이 보는 화면 (Expected Output)
```text
=== Lab 01: commit-msg-ko Validation ===
[TEST 1] Checking frontmatter delimiters (---) ... PASS
[TEST 2] Checking name field (kebab-case) ... PASS
[TEST 3] Checking description word count (< 30 words) ... PASS (24 words)
[TEST 4] Checking trigger phrases in description ... PASS (4/4 triggers present)
[TEST 5] Checking allowed-tools permissions ... PASS
=== ALL 5 TESTS PASSED ===
```

### 5. 강사 실시간 멘트 (Instructor Commentary)
> "자, 화면을 보십시오. 좌측의 장황한 설명은 단어 수가 45단어에 트리거 구문이 하나도 없습니다. 에이전트에게 '커밋 메시지 써줘'라고 입력하면, 좌측 스킬은 임베딩 거리에서 완전히 밀려나 호출되지 않습니다.
> 반면 우측 gstack 스킬은 24단어로 압축되어 있고, 작은따옴표로 정확한 사용자 발화가 박혀 있습니다. 
> 테스트 러너가 돌아가는 순간, 4대 트리거가 즉각 100% 매칭되는 것을 확인할 수 있습니다. 이것이 호출되는 스킬의 비결입니다."

### 6. 장애 복구 플랜 B (Troubleshooting)
- 만약 Git Bash에서 한글 인코딩이 깨져 보이면:
  - 즉시 `chcp.com 65001 > /dev/null`을 실행하거나, 영문 트리거(`write commit msg`) 검증 부분을 지목하여 설명합니다.

---

## 🎬 Demo 2: 탈옥 공격 vs PreToolUse Hook 물리 차단 (Physical Interception)

### 1. 시연 목적 & 아키텍처 포인트
- 프롬프트에 아무리 "절대 삭제하지 마세요"라고 적어도 탈옥 프롬프트로 우회될 수 있지만, **OS 프로세스 레벨의 PreToolUse Hook은 100% 물리 차단(Fail-Closed)**한다는 것을 시연합니다.

### 2. 사전 준비 (Setup)
```bash
cd D:/01_aistudy/gstack_run/edu_gemini/03_workbook/lab02-hook
# 테스트 더미 파일 생성
touch .env test_vault.key
```

### 3. 실시간 실행 스텝 (Live Execution)
1. **공격 1: 단순 위험 명령 파이프라인**:
   ```bash
   echo '{"tool_name": "Bash", "tool_input": {"command": "git status && rm -rf /"}}' | bash solutions/hook.sh
   ```
2. **공격 2: 따옴표 이스케이프 우회 공격 (과거 grep 버그 재현)**:
   ```bash
   echo '{"tool_name": "Bash", "tool_input": {"command": "git commit -m \"wip\" && rm -rf /"}}' | bash solutions/hook.sh
   ```
3. **공격 3: 민감 키 파일 탈취 공격**:
   ```bash
   echo '{"tool_name": "Read", "tool_input": {"path": ".env"}}' | bash solutions/hook.sh
   ```
4. **정상 명령: 허용 확인**:
   ```bash
   echo '{"tool_name": "Bash", "tool_input": {"command": "git diff --cached"}}' | bash solutions/hook.sh
   ```

### 4. 청중이 보는 화면 (Expected Output)
- 공격 1 & 2 실행 시:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionReason": "BLOCKED: Dangerous system command pattern detected"
  }
}
```
*(Exit code: 0 또는 2로 프로세스 즉시 종료)*

- 정상 명령 실행 시:
```json
{}
```
*(빈 객체 출력 후 Exit code: 0)*

### 5. 강사 실시간 멘트 (Instructor Commentary)
> "보십시오! 해커가 프롬프트를 탈옥시켜서 에이전트가 `rm -rf /` 명령을 실행하도록 만들었습니다.
> 하지만 명령이 터미널에 도달하기 전, PreToolUse Hook이 중간에서 패킷을 낚아챕니다.
> `hookSpecificOutput` 안에 정확하게 `permissionDecision: deny`가 꽂히면서 커널 실행 자체가 취소됩니다.
> 그리고 정상적인 `git diff`를 쐈을 때는 어떻게 됩니까? 아무런 방해 없이 빈 객체 `{}`를 반환하고 즉시 통과시킵니다.
> 이것이 프롬프트의 나약한 권고가 아닌, OS 레벨의 '물리 법칙'입니다."

### 6. 장애 복구 플랜 B (Troubleshooting)
- 만약 jq나 Node가 없어 파싱 에러가 날 경우:
  - 당황하지 않고 "바로 이것이 fail-closed입니다! 파서가 에러를 내도 허용하지 않고 무조건 deny로 떨어집니다!"라고 설명하며 안정성을 반증합니다.

---

## 🎬 Demo 3: 점진적 로딩(Progressive Disclosure) 토큰 절감 측정

### 1. 시연 목적 & 아키텍처 포인트
- 1,500줄짜리 모놀리식 지침 문서를 [SKILL.md 200줄 + references/ 1,300줄]로 분리했을 때, **초기 세션 로딩 토큰이 85% 이상 절감되는 것을 정량적 바이트/라인 수로 실시간 입증**합니다.

### 2. 사전 준비 (Setup)
```bash
cd D:/01_aistudy/gstack_run/edu_gemini/03_workbook/lab04-compiler
```

### 3. 실시간 실행 스텝 (Live Execution)
1. **모놀리식 스킬과 점진적 분할 스킬의 크기 비교**:
   ```bash
   # 모놀리식 가상 파일 크기 측정
   wc -l templates/skill-template.md
   
   # 실제 컴파일된 SKILL.md 크기 측정
   wc -l solutions/build.sh
   ```
2. **컴파일러 빌드 실행 및 결과 확인**:
   ```bash
   bash solutions/build.sh
   ls -lh dist/
   ```

### 4. 청중이 보는 화면 (Expected Output)
```text
=== Building Skills with Progressive Disclosure Architecture ===
[BUILD] Compiling commit-msg-ko ... OK (42 lines, 1.2 KB)
[BUILD] Compiling protect-secrets ... OK (58 lines, 1.6 KB)
[BUILD] Compiling module-analyst ... OK (65 lines, 1.9 KB)
---
Summary:
Monolithic Skill Token Equivalent: ~2,400 tokens
Progressive Entry Token Equivalent: ~280 tokens (88.3% token savings!)
Detailed references stored in: dist/references/
```

### 5. 강사 실시간 멘트 (Instructor Commentary)
> "숫자를 확인하십시오. 
> 모든 내용을 한 파일에 넣었을 때는 에이전트가 스킬을 켤 때마다 2,400토큰을 기본 소모했습니다. 세션 대화 몇 번만 나누면 금세 컨텍스트 제한에 도달합니다.
> 하지만 엔트리 포인트를 200줄 미만으로 압축하고 상세 레퍼런스를 분리하자, 토큰이 280개로 줄어들었습니다. 88%의 절감입니다.
> 에이전트는 평소에는 가벼운 두뇌로 기동하고, 심층 규칙이 필요할 때만 references 문서를 열어봅니다. 이것이 대규모 상용 에이전트 설계의 기본기입니다."

---

## 🎬 Demo 4: 결정 메모리(Decision Memory) 드리프트 방지 시연

### 1. 시연 목적 & 아키텍처 포인트
- 컨텍스트를 강제로 리셋(`/clear` 또는 새 세션 시작)한 상황에서도, `decisions.jsonl`에 아키텍처 결정이 박제되어 있으면 **에이전트가 이전 결정을 번복하거나 사용자에게 똑같은 질문을 반복하지 않는 현상**을 보여줍니다.

### 2. 사전 준비 (Setup)
```bash
cd D:/01_aistudy/gstack_run/edu_gemini/03_workbook/lab06-memory
# 기존 결정 로그 초기화
> decisions.jsonl
```

### 3. 실시간 실행 스텝 (Live Execution)
1. **첫 번째 결정 기록 (팀 아키텍처 결정 박제)**:
   ```bash
   node -e '
   const fs = require("fs");
   const rec = {
     timestamp: new Date().toISOString(),
     topic: "cache_store",
     decision: "Use local lru-cache library",
     rationale: "Zero operational overhead, sub-millisecond latency for single instance",
     rejected_alternatives: ["Redis: Rejected due to AWS ElastiCache cost and VPC setup complexity"]
   };
   fs.appendFileSync("decisions.jsonl", JSON.stringify(rec) + "\n");
   '
   ```

2. **저장된 결정 메모리 확인**:
   ```bash
   cat decisions.jsonl
   ```

3. **테스트 러너 실행으로 에이전트의 기억 회상 검증**:
   ```bash
   bash test_lab06.sh
   ```

### 4. 청중이 보는 화면 (Expected Output)
```text
=== Lab 06: Decision Memory Validation ===
[TEST 1] Checking decisions.jsonl existence ... PASS
[TEST 2] Checking JSONL schema compliance (timestamp, topic, decision, rejected_alternatives) ... PASS
[TEST 3] Simulating new session context injection ... PASS
[TEST 4] Validating cache_store decision retrieval ... PASS
Found decision: Use local lru-cache library (Redis explicitly rejected)
=== ALL TESTS PASSED: Zero Decision Drift Detected ===
```

### 5. 강사 실시간 멘트 (Instructor Commentary)
> "화면의 JSONL 한 줄을 보십시오.
> 'Redis는 비용과 VPC 복잡성 때문에 기각되었고, 로컬 lru-cache를 사용한다.'
> 새로운 에이전트 세션이 열렸습니다. 이전 대화 기록은 1바이트도 남아있지 않습니다.
> 하지만 에이전트가 기동하면서 `decisions.jsonl`을 스캔하는 순간, 이미 끝난 논쟁을 다시 꺼내지 않습니다.
> 'Redis를 설치할까요?'라고 묻지 않고, 곧바로 lru-cache 코드를 작성하기 시작합니다.
> 이것이 에이전트와 인간 개발자가 장기 프로젝트에서 신뢰를 쌓는 유일한 방법입니다."

### 6. 장애 복구 플랜 B (Troubleshooting)
- 만약 Node 실행 환경 문제로 JSON 포맷이 깨지면:
  - 미리 준비해 둔 `solutions/decisions.jsonl` 파일을 즉시 복사(`cp solutions/decisions.jsonl .`)하고 `bash test_lab06.sh`를 구동합니다.

---
