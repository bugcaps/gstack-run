#!/usr/bin/env bash
# Lab 02 Starter: check-secrets.sh
set -euo pipefail

INPUT=$(cat)

# TODO: 진짜 JSON 파서(Node/Python)로 tool_input.file_path 추출
# TODO: .env, *.key, *.pem 등 기밀 파일 감지 시 deny 출력
# TODO: 일반 파일 통과 시 echo '{}' 출력

echo '{}'
