#!/usr/bin/env bash
# Lab 04 컴파일러 및 린터 검증 테스트 러너 (Bash)
set -euo pipefail

TARGET_DIR="${1:-starter}"
if [ "$TARGET_DIR" = "solution" ] || [ "$TARGET_DIR" = "solutions" ]; then
  TARGET_DIR="../solutions/lab04-compiler"
fi

echo "=== [Lab 04] skill-compiler 검증: $TARGET_DIR ==="

cd "$TARGET_DIR"
bash gen.sh
bash validate.sh

echo ""
echo "✅ Lab 04 컴파일러 테스트 100% 통과!"
