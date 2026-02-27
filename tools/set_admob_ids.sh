#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IOS_PLIST="$ROOT_DIR/ios/Runner/Info.plist"
ANDROID_MANIFEST="$ROOT_DIR/android/app/src/main/AndroidManifest.xml"

IOS_ADMOB_APP_ID="ca-app-pub-8707491489514576~3053779336"
ANDROID_ADMOB_APP_ID="ca-app-pub-8707491489514576~2318954189"

if /usr/libexec/PlistBuddy -c "Print :GADApplicationIdentifier" "$IOS_PLIST" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :GADApplicationIdentifier $IOS_ADMOB_APP_ID" "$IOS_PLIST"
else
  /usr/libexec/PlistBuddy -c "Add :GADApplicationIdentifier string $IOS_ADMOB_APP_ID" "$IOS_PLIST"
fi

perl -0pi -e 's#\s*<meta-data android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID" android:value="[^"]*"\s*/>\s*##gms' "$ANDROID_MANIFEST"
perl -0pi -e 's#(<application\b[^>]*>)#$1\n        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="'"$ANDROID_ADMOB_APP_ID"'"/>\n#s' "$ANDROID_MANIFEST"

grep -n "GADApplicationIdentifier" "$IOS_PLIST" || true
grep -n "com.google.android.gms.ads.APPLICATION_ID" "$ANDROID_MANIFEST" || true
