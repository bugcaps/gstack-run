# 13강 [심화]. 세션 간 결정 메모리: The Blackboard Memory Pattern

**원본:** `gstack/CLAUDE.md` ("Cross-session decision memory" 전문)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 에이전트의 치명적 결함: 기억 상실 (Session Amnesia)

모든 LLM 대화 세션은 본질적으로 **무상태(Stateless)**입니다.
- 오늘 세션에서 개발자가 "A 라이브러리는 Windows에서 메모리 누수가 있으니 B 라이브러리를 쓰자"라고 결정했습니다.
- 내일 새 세션을 열면, 새 모델은 어제의 결정을 전혀 알지 못합니다.
- 다시 A 라이브러리를 쓰다가 똑같은 메모리 누수를 겪으며 삽질을 반복합니다.

---

## 2. 불변 추가 전용 결정 로그 (`decisions.jsonl`)

gstack은 세션 너머로 지식을 계승하기 위해 가장 단순하고 강력한 **블랙보드 메모리 패턴**을 도입했습니다:

`gstack/CLAUDE.md` 발췌:
```markdown
### Cross-session decision memory

When making significant architectural decisions or fixing non-obvious bugs,
record the rationale in the append-only decision log:

```bash
# Append decision entry
printf '{"timestamp":"%s","skill":"%s","decision":"%s","rationale":"%s"}\n' \
  "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SKILL_NAME" "$DECISION" "$RATIONALE" >> .claude/decisions.jsonl
```

Before attempting non-trivial refactorings, search the log:
```bash
grep -i "keyword" .claude/decisions.jsonl || true
```

Rules:
- Append-only: never edit or delete past entries.
- Record the WHY, not just the WHAT (include alternatives rejected).
```

📝 **엔지니어링 의의**:
1. **불변 추가 전용 (Append-Only)**: 과거의 결정을 덮어쓰거나 지우지 않습니다. 시간 순서대로 지식이 누적됩니다.
2. **이유(WHY)의 기록**: 무엇을 바꿨는지(WHAT)보다 **"왜 그렇게 결정했는지(WHY)"**와 탈락시킨 대안을 기록합니다.
3. **초고속 검색**: 복잡한 벡터 DB 없이도 순수 `grep` 한 줄로 0.001초 만에 과거 결정을 조회할 수 있습니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab06-memory](../../03_workbook/lab06-memory/)**: 아키텍처 결정을 `decisions.jsonl`에 안전하게 기록하고 검색하는 `decision-memory` 스킬을 직접 구축합니다.
