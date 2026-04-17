#!/usr/bin/env bash
# Build ritual-voice.skill from the skill/ directory.
# Output: dist/ritual-voice.skill
#
# A .skill file is a zip archive with a skill-name/ folder at the root
# containing SKILL.md and any referenced files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="ritual-voice"
SRC="${ROOT}/skill"
DIST="${ROOT}/dist"
STAGE="$(mktemp -d)"

trap 'rm -rf "${STAGE}"' EXIT

if [ ! -f "${SRC}/SKILL.md" ]; then
  echo "error: ${SRC}/SKILL.md not found" >&2
  exit 1
fi

mkdir -p "${DIST}"
mkdir -p "${STAGE}/${SKILL_NAME}"

cp -r "${SRC}/"* "${STAGE}/${SKILL_NAME}/"

OUT="${DIST}/${SKILL_NAME}.skill"
rm -f "${OUT}"

(cd "${STAGE}" && zip -qr "${OUT}" "${SKILL_NAME}")

SIZE=$(wc -c < "${OUT}" | tr -d ' ')
SHA=$(shasum -a 256 "${OUT}" | awk '{print $1}')

echo "built: ${OUT}"
echo "size:  ${SIZE} bytes"
echo "sha256: ${SHA}"
