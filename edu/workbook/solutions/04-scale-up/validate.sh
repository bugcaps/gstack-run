#!/usr/bin/env bash
# validate.sh — SKILL.md frontmatter 검사기 (gstack test/skill-validation.test.ts 의 축소판)
# 사용: bash validate.sh <SKILL.md> [...]      하나라도 실패하면 exit 1
# 규칙: 1) 첫 줄 '---' 이고 frontmatter가 닫힘  2) name 존재, [a-z0-9-]+, 폴더명과 같음
#       3) description 존재, 1024자 이하        4) "Use when" 포함 (파일 어디든)
export LC_ALL=C.UTF-8
FAIL=0
for f in "$@"; do
  errs=()
  [ "$(head -n1 "$f")" = "---" ] || errs+=("첫 줄이 --- 가 아님")
  [ "$(grep -c '^---$' "$f")" -ge 2 ] || errs+=("frontmatter가 닫히지 않음")
  fm=$(awk '/^---$/{n++; next} n==1' "$f")
  name=$(sed -n 's/^name:[[:space:]]*//p' <<<"$fm" | head -n1)
  dir=$(basename "$(dirname "$f")")
  if [ -z "$name" ]; then errs+=("name 없음")
  else
    [[ "$name" =~ ^[a-z0-9-]+$ ]] || errs+=("name '$name' 형식 오류 ([a-z0-9-]+)")
    [ "$name" = "$dir" ] || errs+=("name '$name' ≠ 폴더명 '$dir'")
  fi
  # description: 한 줄형(description: xxx) 과 블록형(description: | + 들여쓴 줄) 모두 지원
  desc=$(awk '/^description:/{sub(/^description:[[:space:]]*/,""); if ($0!="|" && $0!=">") print; on=1; next}
              on && /^[[:space:]]/{sub(/^[[:space:]]+/,""); print; next} {on=0}' <<<"$fm" | tr '\n' ' ')
  desc=${desc% }
  if [ -z "$desc" ]; then errs+=("description 없음")
  elif [ "${#desc}" -gt 1024 ]; then errs+=("description ${#desc}자 (> 1024)"); fi
  grep -qi 'use when' "$f" || errs+=("\"Use when\" 트리거 문장 없음")
  if [ ${#errs[@]} -eq 0 ]; then echo "OK    $f"
  else FAIL=1; for e in "${errs[@]}"; do echo "FAIL  $f: $e"; done; fi
done
exit $FAIL
