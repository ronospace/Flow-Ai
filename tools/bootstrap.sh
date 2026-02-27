#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IOS_PLIST="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
ANDROID_JSON="$ROOT_DIR/android/app/google-services.json"

IOS_INFO_PLIST="$ROOT_DIR/ios/Runner/Info.plist"
ANDROID_MANIFEST="$ROOT_DIR/android/app/src/main/AndroidManifest.xml"

die() { echo "❌ $*" >&2; exit 1; }
ok()  { echo "✅ $*"; }

require_file() {
  [[ -f "$1" ]] || die "Missing file: $1"
  ok "Found: $1"
}

require_plist_key() {
  local plist="$1" key="$2"
  /usr/libexec/PlistBuddy -c "Print :$key" "$plist" >/dev/null 2>&1 \
    || die "Missing plist key '$key' in $plist"
  ok "Info.plist has key: $key"
}

require_android_meta() {
  local manifest="$1" name="$2"
  grep -qE "android:name=\"${name}\"" "$manifest" \
    || die "Missing Android manifest meta-data: $name in $manifest"
  ok "AndroidManifest has meta-data: $name"
}

echo "== Flow AI bootstrap checks =="

require_file "$IOS_PLIST"
require_file "$ANDROID_JSON"

require_file "$IOS_INFO_PLIST"
require_file "$ANDROID_MANIFEST"

require_plist_key "$IOS_INFO_PLIST" "GADApplicationIdentifier"
require_android_meta "$ANDROID_MANIFEST" "com.google.android.gms.ads.APPLICATION_ID"

echo ""
ok "Bootstrap checks passed."
