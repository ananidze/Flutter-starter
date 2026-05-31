#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== . =="
dart analyze .

while IFS= read -r pubspec; do
  dir="${pubspec%/pubspec.yaml}"
  echo
  echo "== ${dir} =="
  (cd "$dir" && dart analyze .)
done < <(find packages -maxdepth 4 -name pubspec.yaml | sort)
