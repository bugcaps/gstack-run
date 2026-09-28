# 10강 [심화]. 프로덕션 런타임 프로토콜과 Degraded 모드: The Fault-Tolerant Runtime

**원본:** `gstack/ARCHITECTURE.md` (The daemon model & Degraded mode), `gstack/browse/src/server.ts`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 스킬의 라이프사이클과 STATUS 시그널

단순한 프롬프트는 실행 도중 화면이 멈추거나 침묵하여 사용자를 답답하게 만듭니다.  
gstack 스킬은 시작할 때 반드시 표준 런타임 상태를 화면에 출력합니다:

```text
STATUS: RUNNING [investigate] Phase 1/5 (Triage)
```

- 사용자는 현재 에이전트가 어떤 스킬의 몇 번째 단계에 위치해 있는지 즉시 인지할 수 있습니다.
- 백그라운드 CI 파이프라인에서도 로그를 파싱하여 진행률을 모니터링할 수 있습니다.

---

## 2. 프로덕션 내결함성: Degraded Mode (우아한 기능 저하)

gstack의 가장 놀라운 아키텍처적 특성은 **"외부 도구가 죽어도 스킬은 멈추지 않는다"**는 점입니다.

`gstack/ARCHITECTURE.md` 발췌:
```markdown
When Aside is not installed or not running — Linux, Windows, a closed Aside app —
gstack falls back, automatically, to the browser it ships itself: a persistent headless
Chromium daemon behind a compiled CLI ($B).

Without Aside it uses the host's WebSearch tool when there is one, and otherwise
says "Search unavailable" once and carries on in DEGRADED MODE.
```

```
[브라우저/인터넷 정상] ──▶ Headless Chromium / Aside로 실제 렌더링 & 스크린샷 검증
           │ (실패 / 미설치 / 포트 충돌)
           ▼
[Degraded Mode 전환] ──▶ 조용히 죽지 않고, 터미널 텍스트 기반(Curl/Grep)으로 우회하여 임무 완수
```

📝 **엔지니어링 의의**:
- 에이전트 도구가 환경 문제로 실패했을 때 예외를 뿜고 크래시되는 것이 아니라, **차선책(Fallback)으로 우아하게 다운그레이드(Graceful Degradation)**하여 사용자의 작업을 끝까지 마무리합니다.
- 이것이 토이 프로젝트와 프로덕션 엔터프라이즈 시스템의 결정적 차이입니다.
