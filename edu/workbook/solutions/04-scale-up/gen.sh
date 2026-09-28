#!/usr/bin/env bash
# gen.sh — gstack scripts/gen-skill-docs.ts 의 축소판.
#   src/<name>/SKILL.md.tmpl 의 "{{NAME}}" 한 줄 → partials/<name 소문자>.md 내용
#   결과: out/<name>/SKILL.md (frontmatter 바로 뒤에 AUTO-GENERATED 주석)
# 사용: bash gen.sh             생성
#       bash gen.sh --dry-run   생성하지 않고 out/ 이 최신인지만 확인 (다르면 exit 1)
set -euo pipefail
cd "$(dirname "$0")"
MODE=${1:-}; STALE=0
for tmpl in src/*/SKILL.md.tmpl; do
  name=$(basename "$(dirname "$tmpl")"); out="out/$name/SKILL.md"
  rendered=$(awk '
    /^\{\{[A-Z_]+\}\}$/ { f = "partials/" tolower(substr($0, 3, length($0) - 4)) ".md"
      if ((getline line < f) <= 0) { print "missing partial: " f > "/dev/stderr"; exit 2 }
      print line; while ((getline line < f) > 0) print line; close(f); next }
    { print }
    /^---$/ && ++fm == 2 { print "<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->" }
  ' "$tmpl")
  if grep -q '{{' <<<"$rendered"; then echo "unresolved placeholder in $tmpl" >&2; exit 1; fi
  if [ "$MODE" = "--dry-run" ]; then
    [ "$(cat "$out" 2>/dev/null)" = "$rendered" ] || { echo "STALE: $out"; STALE=1; }
  else
    mkdir -p "out/$name"; printf '%s\n' "$rendered" > "$out"; echo "wrote $out"
  fi
done
exit $STALE
