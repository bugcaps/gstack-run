# gstack 아키텍처 맵 & 시스템 시퀀스 (Architecture Map)

이 문서는 Garry Tan의 `gstack` (v1.91.1)이 채택한 시스템 엔지니어링 아키텍처를 시각화합니다.

---

## 1. 4계층 스킬 플릿 아키텍처 (Layered Architecture)

62개 스킬은 단일 목록이 아니라, 명확한 책임과 생명주기를 가진 4개 레이어로 편제됩니다:

```mermaid
flowchart TD
    subgraph L4 ["Layer 4: 메타 관제 & 메모리 (Meta / Orchestration)"]
        Router["/gstack-router (관제탑 메타 라우터)"]
        Skillify["/skillify (스킬 자동 생성 메타 스킬)"]
        Decisions["/learn & decisions.jsonl (세션 불변 결정 메모리)"]
    end

    subgraph L3 ["Layer 3: 워크플로 스킬 (Workflows & Pipelines)"]
        Investigate["/investigate (5단계 디버깅)"]
        Review["/review (시니어 엔지니어 코드 리뷰)"]
        Autoplan["/autoplan (CEO-Design-DevEx-Eng 기획 파이프라인)"]
        Ship["/ship & /land-and-deploy (릴리즈 엔지니어링)"]
    end

    subgraph L2 ["Layer 2: 결정적 워커 & 도구 (Deterministic Workers)"]
        Unfreeze["/unfreeze (락 해제)"]
        Browse["/browse & /scrape (듀얼 브라우저 조작)"]
        Diagram["/diagram (Excalidraw/Mermaid 생성)"]
        BrowserSkills["browser-skills/ (TypeScript + Playwright + Fixtures)"]
    end

    subgraph L1 ["Layer 1: 보안 & 정책 하드 가드 (Physical Safety Guards)"]
        Careful["/careful (파괴적 커맨드 감시 훅)"]
        Freeze["/freeze (수정 디렉토리 범위 잠금 훅)"]
        Guard["/guard (Careful + Freeze 무코드 컴포지션)"]
    end

    Router --> L3
    Router --> L2
    L3 --> L1
    L2 --> L1
```

---

## 2. PreToolUse Hook 물리적 차단 시퀀스

프롬프트와 달리, 모델의 도구 호출을 OS 쉘 프로세스가 중간에서 물리적으로 가로채는 흐름입니다:

```mermaid
sequenceDiagram
    autonumber
    actor User as 사용자
    participant LLM as AI 모델 (추론 엔진)
    participant Host as 런타임 호스트 (Claude Code / Agent)
    participant Hook as check-careful.sh (로컬 Bash 프로세스)
    participant OS as 운영체제 쉘 (Bash / System Call)

    User->>LLM: "빌드 아티팩트 정리해줘"
    LLM->>Host: 도구 호출 요청: Bash("git commit -m 'wip' && rm -rf /")
    Host->>Hook: stdin 파이프로 JSON 전송: {"tool_input":{"command":"..."}}
    Note over Hook: 진짜 JSON 파서(Node/Python)로 CMD 파싱<br/>정규식 따옴표 절단 버그 방어<br/>위험도 2-Tier 판정 (HIGH: deny, MEDIUM: ask)
    alt 파멸적 명령어 감지 (HIGH Tier)
        Hook-->>Host: stdout: {"hookSpecificOutput":{"permissionDecision":"deny"}}
        Host-->>LLM: 도구 실행 거절 통보 (OS 시스템 콜 원천 차단)
        LLM-->>User: "루트 삭제 위험 명령이 감지되어 실행이 물리적으로 차단되었습니다."
    else 안전 예외 (node_modules 삭제 등)
        Hook-->>Host: stdout: {} (빈 JSON 객체)
        Host->>OS: 실제 시스템 콜 실행
        OS-->>Host: 실행 결과 반환
        Host-->>LLM: 도구 실행 결과 전달
    end
```

---

## 3. 듀얼 브라우징 엔진 아키텍처 (`ARCHITECTURE.md`)

에이전트가 브라우저를 볼 때 취하는 gstack의 2단계 폴백 아키텍처입니다:

```mermaid
flowchart LR
    Agent["AI 에이전트"] --> Probe{"Aside 브라우저 설치됨?<br/>(macOS 15+)"}
    
    Probe -->|"YES (1st Engine)"| Aside["Aside AI 브라우저<br/>• 실제 사용자 프로필 & 열린 탭<br/>• 실제 로그인 쿠키 그대로 사용<br/>• exit 0 + GSTACK_STEP_OK 증거 라인"]
    
    Probe -->|"NO (Fallback Engine)"| Daemon["Headless Chromium 데몬 ($B)<br/>• 백그라운드 상주 프로세스<br/>• localhost:PORT HTTP POST 통신<br/>• 100~200ms 서브세컨드 레이턴시"]
```
