#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${ADMOB_IOS_APP_ID:?Set ADMOB_IOS_APP_ID (ca-app-pub-...)}"
: "${ADMOB_ANDROID_APP_ID:?Set ADMOB_ANDROID_APP_ID (ca-app-pub-...)}"

IOS_INFO_PLIST="$ROOT_DIR/ios/Runner/Info.plist"
ANDROID_MANIFEST="$ROOT_DIR/android/app/src/main/AndroidManifest.xml"

die() { echo "❌ $*" >&2; exit 1; }
ok()  { echo "✅ $*"; }

[[ -f "$IOS_INFO_PLIST" ]] || die "Missing: $IOS_INFO_PLIST"
[[ -f "$ANDROID_MANIFEST" ]] || die "Missing: $ANDROID_MANIFEST"

echo "== Injecting AdMob App IDs =="

# iOS: Info.plist -> GADApplicationIdentifier
/usr/libexec/PlistBuddy -c "Delete :GADApplicationIdentifier" "$IOS_INFO_PLIST" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :GADApplicationIdentifier string ${ADMOB_IOS_APP_ID}" "$IOS_INFO_PLIST"
ok "iOS Info.plist updated: GADApplicationIdentifier"

# Android: AndroidManifest.xml -> meta-data value for APPLICATION_ID
# Replaces android:value="..." ONLY for the matching meta-data entry
perl -0777 -i -pe '
  my $name = "com.google.android.gms.ads.APPLICATION_ID";
  my $id = $ENV{"ADMOB_ANDROID_APP_ID"};
  if ($_ !~ /android:name="\Q$name\E"/) { die "meta-data $name not found\n"; }
  s{(<meta-data\s+android:name="\Q$name\E"\s+android:value=")[^"]*(")}{$1$id$2}gms;
' "$ANDROID_MANIFEST"

ok "AndroidManifest updated: com.google.android.gms.ads.APPLICATION_ID"
echo "Done."
