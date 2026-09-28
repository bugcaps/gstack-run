# 01강. 스킬의 해부 구조와 자연어 라우팅 엔진 (Anatomy & Routing)

**원본:** `gstack/unfreeze/SKILL.md` (전문 48줄), `gstack/ETHOS.md` (34–62행)  
**기준:** gstack v1.91.1 (Commit `2a113ae7`), MIT License

---

## 1. 아키텍처 철학: 유닉스 미니멀리즘과 Boil the Ocean

AI 에이전트를 개발할 때 많은 엔지니어들이 LangChain, AutoGen 등 복잡한 Python 객체 지향 프레임워크를 먼저 떠올립니다. 하지만 Garry Tan의 `gstack`은 정반대의 길을 선택했습니다: **"폴더 하나, 마크다운 하나, 쉘 스크립트 하나"**.

`gstack/ETHOS.md` (34–45행):
```markdown
## 1. Boil the Ocean

"Don't boil the ocean" was the right advice when engineering time was the
bottleneck. That era is over. AI-assisted coding makes the marginal cost of
completeness near-zero, so the old caution has quietly turned into an excuse.
When the complete implementation costs minutes more than the shortcut — do the
complete thing. Every time.
```

📝 **아키텍처 통찰**:
- 완결성을 추구하되, 추상화 레이어를 겹겹이 쌓지 않습니다.
- 50줄짜리 쉘 명령으로 끝낼 수 있는 일을 위해 500줄짜리 파이썬 클래스를 만들지 않는 것이 gstack의 제1원칙입니다.

---

## 2. 48줄짜리 최소 스킬 전문 해부 (`unfreeze/SKILL.md`)

```markdown
1: ---
2: name: unfreeze
3: description: Unfreezes the codebase by removing the edit lock. Run this when you need to make changes to files outside the frozen directory.
4: allowed-tools:
5:   - Bash
6: ---
7: 
8: # Unfreeze
9: 
10: Remove the edit lock by deleting the lock file.
11: 
12: Run:
13: ```bash
14: rm -f .claude/freeze-lock.json
15: ```
16: 
17: Confirm the lock is removed:
18: - If the file was deleted successfully, tell the user the codebase is now unfrozen.
19: - If the file did not exist, inform the user that no lock was active.
```

---

## 📝 심층 주석 및 엔지니어링 해설

### ① `name` (2행)
- 디렉토리명(`unfreeze/`)과 100% 일치해야 하는 고유 ID입니다.
- 불일치 시 런타임이 스킬을 로드하지 못하거나 슬래시 커맨드(`/<name>`)가 동작하지 않습니다.

### ② `description` = 자연어 라우팅 엔진 (3행)
- **가장 치명적인 착각**: "마크다운 본문에 1,000줄을 잘 써두면 모델이 알아서 읽겠지."
- **실제 런타임의 동작**: 모델은 세션 시작 시 **본문 마크다운을 절대 읽지 않습니다.** (수만 토큰 낭비 방지).
- 모델은 오직 이 `description` 한 줄만 시스템 프롬프트(카탈로그)에 올려두고 사용자 프롬프트와 매칭합니다.
- 따라서 description에는 반드시 3가지가 들어가야 합니다:
  1. **무엇을 하는지** (`Unfreezes the codebase by removing the edit lock`)
  2. **어떤 상황에서 쓰는지** (`when you need to make changes to files outside the frozen directory`)
  3. **사용자의 발화 트리거 키워드**

### ③ `allowed-tools` = 최소 권한 원칙 (4–5행)
- `unfreeze`는 `rm -f` 파일 삭제만 수행하면 되므로 오직 `Bash` 도구만 열어두었습니다.
- 여기에 `Edit`, `Write` 도구를 열어주면, 모델이 락 파일을 삭제하는 대신 소스코드를 열어 코멘트를 지우거나 수정하려는 엉뚱한 부작용(Side effect)을 일으킵니다. 도구는 항상 최소화해야 합니다.

### ④ 본문의 간결한 피드백 루프 (17–19행)
- 명령 실행 후 침묵하지 않고, 파일 존재 여부에 따른 명확한 2가지 응답 분기(성공 메시지 vs 이미 비활성 메시지)를 불릿으로 명시합니다.

---

## 🎯 실습 연결
학생용 워크북 **[lab01-routing](../../03_workbook/lab01-routing/)**: 한국어 커밋 제안 스킬 `commit-msg-ko`를 만들며 자연어 라우팅과 `allowed-tools` 최소화를 직접 구현합니다.
