#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-2.0.0}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/release"
ARCHIVE_NAME="project_backup_v${VERSION}.zip"
ARCHIVE_PATH="${OUTPUT_DIR}/${ARCHIVE_NAME}"

mkdir -p "${OUTPUT_DIR}"
rm -f "${ARCHIVE_PATH}"

cd "${PROJECT_ROOT}"
zip -r "${ARCHIVE_PATH}" . \
  -x "*.git*" \
  -x "node_modules/*" \
  -x "build/*" \
  -x ".dart_tool/*" \
  -x "android/.gradle/*" \
  -x "ios/Pods/*" \
  -x "**/__pycache__/*" \
  -x "release/*"

echo "Created ${ARCHIVE_PATH}"
