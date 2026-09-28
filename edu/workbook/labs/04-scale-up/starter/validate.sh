#!/usr/bin/env bash
# validate.sh (starter) — 사용: bash validate.sh <SKILL.md> [...]   실패 있으면 exit 1
export LC_ALL=C.UTF-8
FAIL=0
for f in "$@"; do
  errs=()
  # TODO 1: 첫 줄이 --- 인가
  # TODO 2: frontmatter가 닫혔는가 (--- 가 2개 이상)
  # TODO 3: name 이 있고, [a-z0-9-]+ 이고, 폴더명과 같은가
  # TODO 4: description 이 있고 1024자 이하인가 (한 줄형 / "description: |" 블록형 모두)
  # TODO 5: 파일 어디든 "Use when" 이 있는가 (대소문자 무시)
  if [ ${#errs[@]} -eq 0 ]; then echo "OK    $f"
  else FAIL=1; for e in "${errs[@]}"; do echo "FAIL  $f: $e"; done; fi
done
exit $FAIL
