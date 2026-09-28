#!/usr/bin/env bash
# gen.sh (starter) — src/<name>/SKILL.md.tmpl + partials/*.md → out/<name>/SKILL.md
# 사용: bash gen.sh | bash gen.sh --dry-run
set -euo pipefail
cd "$(dirname "$0")"
MODE=${1:-}; STALE=0
for tmpl in src/*/SKILL.md.tmpl; do
  name=$(basename "$(dirname "$tmpl")"); out="out/$name/SKILL.md"
  # TODO 1: "{{COMMON}}" 처럼 한 줄 전체가 플레이스홀더면 partials/common.md 내용으로 바꾼다.
  #         (awk 권장. 이름은 소문자로 → 파일명)
  # TODO 2: partial 파일이 없으면 에러로 종료.
  # TODO 3: frontmatter 닫는 '---' 바로 뒤에
  #         <!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly --> 한 줄 삽입.
  rendered=$(cat "$tmpl")
  # TODO 4: 결과에 '{{' 가 남아 있으면 에러로 종료 (치환 누락).
  # TODO 5: --dry-run 이면 파일을 쓰지 말고 out 과 비교해서 다르면 "STALE: <out>" 출력 + exit 1
  mkdir -p "out/$name"; printf '%s\n' "$rendered" > "$out"; echo "wrote $out"
done
exit $STALE
