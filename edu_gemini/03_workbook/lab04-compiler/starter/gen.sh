#!/usr/bin/env bash
# Lab 04 Starter: gen.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

COMMON=$(cat partials/common.md)
mkdir -p out

for tmpl in src/*/SKILL.md.tmpl; do
  [ -f "$tmpl" ] || continue
  name=$(basename $(dirname "$tmpl"))
  mkdir -p "out/$name"
  
  # TODO: {{COMMON_SAFEGUARDS}} 를 $COMMON 으로 치환하여 out/$name/SKILL.md 생성
  content=$(cat "$tmpl")
  echo "${content//\{\{COMMON_SAFEGUARDS\}\}/$COMMON}" > "out/$name/SKILL.md"
  echo "Wrote out/$name/SKILL.md"
done
