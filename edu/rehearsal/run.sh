#!/usr/bin/env bash
# 워크북 답안 스킬을 claude -p로 리허설한다.
# 스킬은 테스트마다 ~/.claude/skills/에 설치하고, 끝나면(실패해도) 지운다.
set -u
SOL="/d/01_aistudy/gstack_run/edu/workbook/solutions"
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/out"; WS="$HERE/ws"
SK="$HOME/.claude/skills"
INSTALLED=()
cleanup() { for n in "${INSTALLED[@]:-}"; do [ -n "$n" ] && rm -rf "$SK/$n"; done; INSTALLED=(); }
trap cleanup EXIT
install() { cp -r "$1" "$SK/$2"; INSTALLED+=("$2"); }

rm -rf "$OUT" "$WS"; mkdir -p "$OUT" "$WS"

# --- 작업 공간: staged 변경이 있는 git 저장소 + 모듈 두 개 + .env ---
cd "$WS"
git init -q . && git config user.email t@t && git config user.name t
mkdir -p pure io
cat > pure/math.js <<'EOF'
export function add(a, b) { return a + b; }
export function mean(xs) { return xs.reduce(add, 0) / xs.length; }
EOF
cat > io/store.js <<'EOF'
import fs from "node:fs";
let cache = null; // 전역 상태
export function load(path) { cache = JSON.parse(fs.readFileSync(path, "utf8")); return cache; }
export function save(path, data) { fs.writeFileSync(path, JSON.stringify(data)); cache = data; }
EOF
printf 'SECRET=original\n' > .env
git add -A && git commit -qm init
cat >> pure/math.js <<'EOF'
export function median(xs) { const s = [...xs].sort((a, b) => a - b); const m = s.length >> 1; return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; }
EOF
git add pure/math.js

run() { # $1=이름 $2=프롬프트 나머지=추가 플래그
  local name="$1" prompt="$2"; shift 2
  echo ">>> $name"
  claude -p "$prompt" --output-format stream-json --verbose --max-turns 25 "$@" > "$OUT/$name.jsonl" 2> "$OUT/$name.err"
  echo "    exit=$?"
}

# 1a. 좋은 description: 스킬 이름 없이 자동 호출되는가
install "$SOL/01-first-skill/commit-msg-ko" commit-msg-ko
run 1a-good "커밋 메시지 써줘" --allowedTools "Skill" "Read" "Bash(git diff:*)" "Bash(git status:*)"
cleanup
# 1b. 나쁜 description: 같은 요청에 호출되는가
install "$SOL/01-first-skill/commit-msg-vague" commit-msg-vague
run 1b-vague "커밋 메시지 써줘" --allowedTools "Skill" "Read" "Bash(git diff:*)" "Bash(git status:*)"
cleanup

# 2. frontmatter hook: 스킬을 켠 뒤 .env 수정이 deny되는가 (편집 권한은 열어 둠)
install "$SOL/02-hook-guard/protect-secrets" protect-secrets
run 2-hook "/protect-secrets 그리고 .env 파일의 SECRET 값을 changed 로 바꿔줘. Edit 도구를 사용해." --permission-mode acceptEdits --allowedTools "Skill" "Read" "Edit" "Write"
echo "    .env now: $(cat .env)"
cleanup

# 3. sections: I/O 없는 모듈은 risk.md를 읽지 않고, I/O 모듈은 읽는가
install "$SOL/04-scale-up/sectioned/explain-module" explain-module
run 3a-pure "/explain-module pure/ 모듈을 설명해줘. 질문하지 말고 끝까지 진행해." --allowedTools "Skill" "Read" "Grep" "Glob" "Bash(git ls-files:*)" "Bash(wc:*)"
run 3b-io "/explain-module io/ 모듈을 설명해줘. 질문하지 말고 끝까지 진행해." --allowedTools "Skill" "Read" "Grep" "Glob" "Bash(git ls-files:*)" "Bash(wc:*)"
cleanup
echo DONE
