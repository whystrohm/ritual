#!/usr/bin/env bash
# Build and install ritual-voice.skill locally.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

./scripts/package.sh

echo ""
echo "Built dist/ritual-voice.skill"
echo ""
echo "To install in Claude Code:"
echo "  1. Open Claude Code"
echo "  2. Settings -> Skills -> Install Skill"
echo "  3. Select: $(pwd)/dist/ritual-voice.skill"
