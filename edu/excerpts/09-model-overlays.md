# 09강 [심화]. 동적 모델 오버레이와 상속: The Dynamic Adaptation Pattern

**원본:** `gstack/model-overlays/` (`fable-5.md` 등), `gstack/scripts/resolvers/inherit.ts`  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 모델마다 다른 프롬프트 편향(Bias)

동일한 스킬이라도 실행하는 모델에 따라 행동이 판이하게 달라집니다:
- **모델 A (장황형)**: 지시사항을 잘 따르지만, 말이 너무 길어서 토큰을 낭비함.
- **모델 B (추측형)**: 코드를 너무 성급하게 고치려 들고 디렉토리 탐색을 건너뜀.
- **모델 C (도구 회피형)**: CLI 도구를 직접 돌려보지 않고 머릿속으로만 계산하려 함.

기본 스킬 본문에 특정 모델만을 위한 잔소리를 덕지덕지 붙이면, 다른 모델에서는 불필요한 노이즈가 됩니다.

---

## 2. 해결책: 모델별 오버레이와 `{{INHERIT}}` 상속 래퍼

gstack은 모델 전용 보정 지침을 `model-overlays/`에 독립 파일로 분리합니다:

```text
gstack/
├── investigate/
│   └── SKILL.md.tmpl           # 기본 5단계 디버깅 로직 (순수 비즈니스 명세)
└── model-overlays/
    ├── claude-3-5-sonnet.md     # Sonnet 전용 보정 지침
    └── gpt-4o.md                # GPT-4o 전용 보정 지침
```

### `model-overlays/claude-3-5-sonnet.md` 발췌:
```markdown
{{INHERIT}}

## Model-Specific Behavioral Tuning (Sonnet)
- Conciseness: Skip preamble. Output results directly.
- Tool Calls: Always check exit codes before proceeding to Phase 4.
```

### 컴파일러(`inherit.ts`)의 치환 동작:
```typescript
// inherit.ts 핵심 로직
export function resolveInherit(overlayContent: string, baseContent: string): string {
  return overlayContent.replace("{{INHERIT}}", baseContent);
}
```

📝 **엔지니어링 의의**:
- 객체 지향 프로그래밍의 **상속(Inheritance)** 패턴을 프롬프트 엔지니어링에 구현했습니다.
- 기본 스킬 원본을 건드리지 않고, 타깃 모델에 맞춘 '맞춤형 잔소리 레이어'를 덧붙여 배포합니다.
