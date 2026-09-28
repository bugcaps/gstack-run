#!/usr/bin/env bash
# 데모 1을 위한 초고속 git 임시 작업 공간 세팅
set -euo pipefail
DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DEMO_DIR"

# 1. 임시 작업 폴더 생성
rm -rf test-repo
mkdir test-repo
cd test-repo

# 2. git 저장소 초기화
git init -q
git config user.email "instructor@demo.com"
git config user.name "Instructor"

# 3. 샘플 파일 및 staged 변경 생성
cat > app.js <<'EOF'
function calculateTax(amount, rate) {
  return amount * rate;
}
EOF
git add app.js
git commit -qm "feat: initial commit"

# 4. 버그 수정 및 staged 추가
cat >> app.js <<'EOF'
function formatCurrency(num) {
  return "$" + num.toFixed(2);
}
EOF
git add app.js

echo "✅ 데모용 git 저장소 및 staged 변경(git add app.js) 준비 완료!"
echo "터미널에서 'git status -s'를 쳐보세요."
