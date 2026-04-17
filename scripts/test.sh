#!/usr/bin/env bash
# Run local validation checks before pushing.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

echo "==> Checking skill structure"
test -f skill/SKILL.md || { echo "missing skill/SKILL.md"; exit 1; }
test -f skill/references/config-schema.md || { echo "missing config-schema.md"; exit 1; }
test -f skill/references/checks.md || { echo "missing checks.md"; exit 1; }

echo "==> Checking SKILL.md line count"
lines=$(wc -l < skill/SKILL.md | tr -d ' ')
if [ "$lines" -gt 500 ]; then
  echo "fail: SKILL.md is $lines lines, over 500" >&2
  exit 1
fi
echo "ok: SKILL.md is $lines lines"

echo "==> Validating example configs"
for config in examples/*/ritual.config.json; do
  python3 scripts/validate_config.py "$config"
done

echo "==> All checks passed"
