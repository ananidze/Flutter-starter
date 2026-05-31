#!/usr/bin/env bash
set -euo pipefail

FLAVOR="${1:-production}"
TARGET="${2:-lib/main_${FLAVOR}.dart}"

flutter build apk \
  --flavor "$FLAVOR" \
  --target "$TARGET" \
  --release
