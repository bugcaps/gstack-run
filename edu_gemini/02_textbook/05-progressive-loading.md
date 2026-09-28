# 05강. 점진적 로딩과 가상 컨텍스트: The Virtual Memory Pattern

**원본:** `gstack/autoplan/SKILL.md` (1–60행), `gstack/autoplan/sections/`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 200만 윈도우 시대에도 긴 프롬프트가 실패하는 이유

Gemini 1.5/2.0의 200만 토큰, Claude의 200k 토큰처럼 윈도우가 거대해졌는데도 왜 1,500줄짜리 프롬프트는 여전히 위험할까요?

1. **Attention Sink & Distraction (주의력 분산)**:
   - 지시사항이 1,500줄을 넘어가면 트랜스포머의 어텐션 가중치가 희석됩니다. 앞부분의 제약 조건을 잊어버리는 'Lost in the Middle' 현상이 필연적으로 발생합니다.
2. **토큰 비용 폭탄**:
   - 매 대화 턴마다 1,500줄(수만 토큰)이 계속 인풋으로 들어가면 API 과금 속도가 기하급수적으로 빨라집니다.

---

## 2. On-Demand 점진적 로딩 (Virtual Memory 아키텍처)

gstack의 `/autoplan`(총 1,500줄 규모)은 운영체제의 **가상 메모리 페이징(Paging)** 기법을 프롬프트 엔지니어링에 도입했습니다:

```
autoplan/
├── SKILL.md            # 메인 관제탑 (150줄): 전체 목차와 게이트웨이만 상주
└── sections/           # 필요할 때만 Read 도구로 로딩되는 하위 페이지
    ├── ceo-review.md   # CEO 리뷰 단계(Phase 1) 도달 시에만 로드 (200줄)
    ├── design.md       # 디자인 단계(Phase 2) 도달 시에만 로드 (250줄)
    ├── devex.md        # DX 단계(Phase 3) 도달 시에만 로드 (200줄)
    └── eng-review.md   # 엔지니어링 단계(Phase 4) 도달 시에만 로드 (300줄)
```

### `SKILL.md`의 실제 호출 지시문 발췌:
```markdown
## Phase 1: CEO Review

1. Read `sections/ceo-review.md` using the `Read` tool.
2. Follow the 6 rubric questions specified in that file.
3. Once the user approves the scope, proceed to Phase 2.
4. Do NOT read subsequent section files until their phase is reached.
```

📝 **엔지니어링 효과**:
- 모델의 컨텍스트에는 항상 **메인 목차(150줄) + 현재 단계 섹션(200줄) = 약 350줄**만 상주합니다.
- 전체 컨텍스트의 80% 이상을 절약하면서도, 모델이 현재 단계의 세부 규칙에 100% 집중하도록 보장합니다.
