#!/usr/bin/env bash
# Lab 04 모범 답안: gen.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

COMMON=$(cat ../../lab04-compiler/starter/partials/common.md)
mkdir -p out

for tmpl in ../../lab04-compiler/starter/src/*/SKILL.md.tmpl; do
  [ -f "$tmpl" ] || continue
  dir=$(dirname "$tmpl")
  name=$(basename "$dir")
  outdir="out/$name"
  mkdir -p "$outdir"
  
  content=$(cat "$tmpl")
  echo "${content//\{\{COMMON_SAFEGUARDS\}\}/$COMMON}" > "$outdir/SKILL.md"
  echo "Wrote $outdir/SKILL.md"
done
