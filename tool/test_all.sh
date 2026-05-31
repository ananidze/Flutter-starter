#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEED="${TEST_RANDOMIZE_ORDERING_SEED:-random}"
cd "$ROOT"

if [ -d test ]; then
  echo "== . =="
  flutter test --no-pub --test-randomize-ordering-seed "$SEED"
else
  echo "No root test/ directory; skipping root app tests."
fi

while IFS= read -r pubspec; do
  dir="${pubspec%/pubspec.yaml}"
  if [ -d "$dir/test" ]; then
    echo
    echo "== ${dir} =="
    (cd "$dir" && flutter test --no-pub --test-randomize-ordering-seed "$SEED")
  fi
done < <(find packages -maxdepth 4 -name pubspec.yaml | sort)
