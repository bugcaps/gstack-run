---
name: commit-msg-ko
description: |
  staged 변경(git diff --cached)을 읽고 한국어 Conventional Commit 메시지를 제안한다.
  커밋은 실행하지 않는다. Use when asked to "커밋 메시지 써줘", "커밋 메시지 만들어줘",
  "이 변경 뭐라고 커밋하지", "write a commit message", or "commit msg".
  Proactively invoke when the user is about to commit and asks how to describe the change.
allowed-tools:
  - Bash
  - Read
---

# /commit-msg-ko — staged 변경으로 한국어 커밋 메시지 작성

## 절차
1. staged 변경 확인
   ```bash
   git diff --cached --stat
   git diff --cached
   ```
2. staged 변경이 없으면 **멈춘다**. "staged 변경이 없습니다. `git add`할 파일을 알려주세요." 한 줄만 말한다. 임의로 `git add` 하지 않는다.
3. 메시지 규칙
   - 제목: `<type>: <요약>` — type은 feat / fix / refactor / docs / test / chore 중 하나, 50자 이내, 마침표 없음
   - 본문: "무엇을"이 아니라 **"왜"** 바꿨는지 1~3줄. diff만으로 이유를 알 수 없으면 추측하지 말고 `(이유: ?)`로 비워 둔다.
   - 변경이 서로 무관한 두 가지 이상이면 커밋을 나누자고 제안한다.
4. 커밋은 실행하지 않는다. 메시지만 보여 준다.

## 출력 형식
```text
feat: 로그인 실패 시 재시도 횟수 제한 추가

무차별 대입 시도를 막기 위해 5회 실패 후 10분 잠금.
```
