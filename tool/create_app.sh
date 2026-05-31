#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

STARTER_PACKAGE_NAME="flutter_starter"
STARTER_APP_NAME="Flutter Starter"
STARTER_DESCRIPTION="A Very Good Project created by Very Good CLI."
STARTER_ANDROID_PACKAGE="com.example.verygoodcore.flutter_starter"
STARTER_IOS_BUNDLE_ID="com.example.verygoodcore.flutter-starter"
STARTER_DEEP_LINK_SCHEME="flutterstarter"
STARTER_DEEP_LINK_HOST="example.com"
STARTER_DEV_API_BASE_URL="http://localhost:8080"
STARTER_STAGING_API_BASE_URL="https://staging.api.example.com"
STARTER_PROD_API_BASE_URL="https://api.example.com"
STARTER_KOTLIN_MAIN="android/app/src/main/kotlin/com/example/verygoodcore/flutter/starter/MainActivity.kt"

app_name=""
package_name=""
bundle_id=""
short_name=""
description=""
deep_link_scheme=""
deep_link_host=""
dev_api_base_url=""
staging_api_base_url=""
prod_api_base_url=""
dry_run=false
skip_pub_get=false
force=false

usage() {
  cat <<'USAGE'
Create a new app identity from the Flutter starter.

Usage:
  ./tool/create_app.sh \
    --app-name "Acme Tasks" \
    --bundle-id com.acme.tasks \
    [--package-name acme_tasks] \
    [--short-name "Acme"] \
    [--description "Acme Tasks app."] \
    [--deep-link-scheme acmetasks] \
    [--deep-link-host tasks.acme.com] \
    [--dev-api-base-url http://localhost:8080] \
    [--staging-api-base-url https://staging-api.acme.com] \
    [--prod-api-base-url https://api.acme.com] \
    [--dry-run] [--skip-pub-get] [--force]

Required:
  --app-name       Human-facing app name.
  --bundle-id      Reverse-DNS app id, used for Android and iOS.

Defaults:
  --package-name       derived from --app-name, e.g. "Acme Tasks" -> acme_tasks
  --short-name         same as --app-name
  --description        "<app name> app."
  --deep-link-scheme   package name without underscores
  --deep-link-host     example.com

Safety:
  The script refuses to run in a dirty git worktree unless --force is passed.
  Use --dry-run to preview the replacement counts without modifying files.
USAGE
}

fail() {
  echo "create_app: $*" >&2
  exit 1
}

need_value() {
  local flag="$1"
  local value="${2:-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    fail "$flag requires a value"
  fi
}

derive_package_name() {
  local raw="$1"
  local name
  name="$(
    printf '%s' "$raw" \
      | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//; s/_+/_/g'
  )"
  if [[ "$name" =~ ^[0-9] ]]; then
    name="app_$name"
  fi
  printf '%s' "$name"
}

escape_regex() {
  printf '%s\n' "$1" | sed -E 's/[][(){}.^$*+?|\\/]/\\&/g'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)
      need_value "$1" "${2:-}"
      app_name="$2"
      shift 2
      ;;
    --package-name)
      need_value "$1" "${2:-}"
      package_name="$2"
      shift 2
      ;;
    --bundle-id)
      need_value "$1" "${2:-}"
      bundle_id="$2"
      shift 2
      ;;
    --short-name)
      need_value "$1" "${2:-}"
      short_name="$2"
      shift 2
      ;;
    --description)
      need_value "$1" "${2:-}"
      description="$2"
      shift 2
      ;;
    --deep-link-scheme)
      need_value "$1" "${2:-}"
      deep_link_scheme="$2"
      shift 2
      ;;
    --deep-link-host)
      need_value "$1" "${2:-}"
      deep_link_host="$2"
      shift 2
      ;;
    --dev-api-base-url)
      need_value "$1" "${2:-}"
      dev_api_base_url="$2"
      shift 2
      ;;
    --staging-api-base-url)
      need_value "$1" "${2:-}"
      staging_api_base_url="$2"
      shift 2
      ;;
    --prod-api-base-url)
      need_value "$1" "${2:-}"
      prod_api_base_url="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --skip-pub-get)
      skip_pub_get=true
      shift
      ;;
    --force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

[[ -f pubspec.yaml ]] || fail "run this script from the Flutter starter root"
[[ -f lib/bootstrap.dart ]] || fail "could not find lib/bootstrap.dart"

[[ -n "$app_name" ]] || { usage; fail "--app-name is required"; }
[[ -n "$bundle_id" ]] || { usage; fail "--bundle-id is required"; }

package_name="${package_name:-$(derive_package_name "$app_name")}"
short_name="${short_name:-$app_name}"
description="${description:-$app_name app.}"
deep_link_scheme="${deep_link_scheme:-${package_name//_/}}"
deep_link_host="${deep_link_host:-$STARTER_DEEP_LINK_HOST}"

[[ "$app_name" != *$'\n'* ]] || fail "--app-name cannot contain newlines"
[[ "$short_name" != *$'\n'* ]] || fail "--short-name cannot contain newlines"
[[ "$description" != *$'\n'* ]] || fail "--description cannot contain newlines"
[[ "$package_name" =~ ^[a-z][a-z0-9_]*$ ]] || fail "--package-name must be lower_snake_case"
[[ "$bundle_id" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]] || fail "--bundle-id must be lower reverse-DNS, e.g. com.acme.tasks"
[[ "$deep_link_scheme" =~ ^[a-z][a-z0-9+.-]*$ ]] || fail "--deep-link-scheme must start with a lowercase letter and contain only lowercase letters, digits, '+', '.', '-'"
[[ "$deep_link_host" =~ ^[A-Za-z0-9.-]+$ ]] || fail "--deep-link-host must be a host name without a scheme"

if [[ "$dry_run" == false && "$force" == false ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --short)" ]]; then
    fail "working tree has uncommitted changes; commit/stash them or pass --force"
  fi
fi

if [[ "$deep_link_host" == "$STARTER_DEEP_LINK_HOST" ]]; then
  echo "create_app: using example.com as deep-link host; pass --deep-link-host when you have a real domain." >&2
fi

collect_files() {
  local pattern
  pattern="$(
    printf '%s\n' \
      "$STARTER_PACKAGE_NAME" \
      "$STARTER_APP_NAME" \
      "$STARTER_ANDROID_PACKAGE" \
      "$STARTER_IOS_BUNDLE_ID" \
      "$STARTER_DEEP_LINK_SCHEME" \
      "$STARTER_DEV_API_BASE_URL" \
      "$STARTER_STAGING_API_BASE_URL" \
      "$STARTER_PROD_API_BASE_URL" \
      | sed '/^$/d' \
      | while IFS= read -r item; do escape_regex "$item"; done \
      | paste -sd '|'
  )"

  if command -v rg >/dev/null 2>&1; then
    rg -l --hidden \
      -g '!build/**' \
      -g '!**/.dart_tool/**' \
      -g '!**/.git/**' \
      -g '!ios/Pods/**' \
      -g '!android/.gradle/**' \
      -g '!tool/create_app.sh' \
      -e "$pattern" .
  else
    grep -RIlE \
      --exclude-dir=build \
      --exclude-dir=.dart_tool \
      --exclude-dir=.git \
      --exclude-dir=Pods \
      --exclude=create_app.sh \
      "$pattern" .
  fi
}

mapfile -t files < <(collect_files | sort)

count_matches_in_files() {
  local old="$1"
  shift
  local target_files=("$@")
  local total=0
  local count
  for file in "${target_files[@]}"; do
    [[ -f "$file" ]] || continue
    count="$(OLD="$old" perl -0ne '$c += () = /\Q$ENV{OLD}\E/g; END { print $c + 0 }' "$file")"
    total=$((total + count))
  done
  printf '%s' "$total"
}

replace_text_in_files() {
  local old="$1"
  local new="$2"
  shift 2
  local target_files=("$@")
  local count
  if [[ "${#target_files[@]}" == "0" ]]; then
    return
  fi
  count="$(count_matches_in_files "$old" "${target_files[@]}")"
  if [[ "$count" == "0" ]]; then
    return
  fi

  printf '  %s -> %s (%s matches)\n' "$old" "$new" "$count"
  if [[ "$dry_run" == false ]]; then
    OLD="$old" NEW="$new" perl -0pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "${target_files[@]}"
  fi
}

replace_text() {
  replace_text_in_files "$1" "$2" "${files[@]}"
}

echo "create_app: configuring app identity"
echo "  app name:          $app_name"
echo "  package name:      $package_name"
echo "  bundle id:         $bundle_id"
echo "  deep-link scheme:  $deep_link_scheme"
echo "  deep-link host:    $deep_link_host"
echo "  files scanned:     ${#files[@]}"
if [[ "$dry_run" == true ]]; then
  echo "  mode:              dry run"
fi

replace_text "$STARTER_ANDROID_PACKAGE" "$bundle_id"
replace_text "$STARTER_IOS_BUNDLE_ID" "$bundle_id"
replace_text "$STARTER_PACKAGE_NAME" "$package_name"
replace_text "$STARTER_APP_NAME" "$app_name"
replace_text "$STARTER_DEEP_LINK_SCHEME" "$deep_link_scheme"

description_files=(pubspec.yaml README.md web/manifest.json web/index.html)
deep_link_host_files=(android/app/build.gradle.kts README.md)
api_config_files=(lib/app/config/app_config.dart)

replace_text_in_files "$STARTER_DESCRIPTION" "$description" "${description_files[@]}"
replace_text_in_files "$STARTER_DEEP_LINK_HOST" "$deep_link_host" "${deep_link_host_files[@]}"

if [[ -n "$dev_api_base_url" ]]; then
  replace_text_in_files "$STARTER_DEV_API_BASE_URL" "$dev_api_base_url" "${api_config_files[@]}"
fi
if [[ -n "$staging_api_base_url" ]]; then
  replace_text_in_files "$STARTER_STAGING_API_BASE_URL" "$staging_api_base_url" "${api_config_files[@]}"
fi
if [[ -n "$prod_api_base_url" ]]; then
  replace_text_in_files "$STARTER_PROD_API_BASE_URL" "$prod_api_base_url" "${api_config_files[@]}"
fi

new_kotlin_main="android/app/src/main/kotlin/${bundle_id//./\/}/MainActivity.kt"
if [[ -f "$STARTER_KOTLIN_MAIN" && "$STARTER_KOTLIN_MAIN" != "$new_kotlin_main" ]]; then
  echo "  $STARTER_KOTLIN_MAIN -> $new_kotlin_main"
  if [[ "$dry_run" == false ]]; then
    mkdir -p "$(dirname "$new_kotlin_main")"
    mv "$STARTER_KOTLIN_MAIN" "$new_kotlin_main"
    rmdir -p "$(dirname "$STARTER_KOTLIN_MAIN")" 2>/dev/null || true
  fi
fi

if [[ "$dry_run" == true ]]; then
  echo "create_app: dry run complete; no files were changed."
  exit 0
fi

if [[ "$skip_pub_get" == false ]]; then
  dart pub get
  dart run melos bootstrap
fi

echo "create_app: done."
echo "Next:"
echo "  dart run melos run check"
echo "  flutter run --flavor development --target lib/main_development.dart"
