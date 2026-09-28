# Lab 01: 자연어 라우팅 & 권한 잠금 — `commit-msg-ko`

## 🎯 실습 목표
1. YAML frontmatter의 필수 필드(`name`, `description`, `allowed-tools`)를 작성한다.
2. 스킬 이름을 직접 부르지 않아도 사용자의 발화("커밋 메시지 써줘")에 모델이 스스로 반응하는 **자연어 라우팅 description**을 작성한다.
3. 파일 수정 도구(`Edit`, `Write`)를 배제하고 읽기 도구만 열어 최소 권한 원칙을 강제한다.

---

## 📋 과제
`starter/SKILL.md`를 열고 다음 3가지를 완성하세요:
1. **name**: `commit-msg-ko`
2. **description**:
   - 역할: `staged 변경(git diff --cached)을 읽고 한국어 Conventional Commit 메시지를 제안한다. 커밋은 실행하지 않는다.`
   - 트리거: `Use when asked to '커밋 메시지 써줘', '커밋 메시지 만들어줘', 'write a commit message'.`
3. **allowed-tools**: `Bash(git diff:*)`, `Bash(git status:*)`, `Read` 만 허용.
4. **본문 지시문**:
   - `git diff --cached`를 확인하여 3가지 대안을 제시할 것.
   - 사용자의 명시적 승인 없이 `git commit`을 절대 실행하지 말 것.
