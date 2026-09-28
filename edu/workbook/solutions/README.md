# 참고 답안

먼저 직접 풀어 본 뒤에 여세요. 정답은 하나가 아닙니다. 성공 기준을 통과하면 됩니다.

| 랩 | 파일 | 확인 명령 |
|---|---|---|
| 01 | `01-first-skill/commit-msg-ko/SKILL.md`, 비교용 `commit-msg-vague/SKILL.md` | 새 세션에서 호출 실험 (자동 테스트 없음) |
| 02 | `02-hook-guard/protect-secrets/{SKILL.md,bin/check-secrets.sh}`, `02-hook-guard/safe-mode/SKILL.md` | `bash ../labs/02-hook-guard/test-hook.sh 02-hook-guard/protect-secrets/bin/check-secrets.sh` → `10 passed, 0 failed` |
| 03 | `03-workflow-skill/explain-module/SKILL.md` | 실제 저장소에서 실행 |
| 04 | `04-scale-up/{gen.sh,validate.sh,partials/,src/,out/,sectioned/}` | `bash 04-scale-up/gen.sh --dry-run` → exit 0<br>`bash 04-scale-up/validate.sh 04-scale-up/out/*/SKILL.md` → 모두 OK<br>`bash 04-scale-up/validate.sh ../labs/04-scale-up/fixtures/*/SKILL.md` → good-skill만 OK |

설치 예:
```bash
cp -r 02-hook-guard/protect-secrets ~/.claude/skills/
cp -r 02-hook-guard/safe-mode ~/.claude/skills/      # gstack(careful)도 설치되어 있어야 함
```
