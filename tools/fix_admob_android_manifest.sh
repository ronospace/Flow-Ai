#!/usr/bin/env bash
set -euo pipefail

ANDROID_MANIFEST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/android/app/src/main/AndroidManifest.xml"
ANDROID_ADMOB_APP_ID="ca-app-pub-8707491489514576~2318954189"

perl -0pi -e 's#\s*<meta-data android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID" android:value="[^"]*"\s*/>\s*##gms' "$ANDROID_MANIFEST"

perl -0pi -e 's#(<application\b[^>]*>)#$1\n        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="'"$ANDROID_ADMOB_APP_ID"'"/>\n#s' "$ANDROID_MANIFEST"

perl -0pi -e 's#(/>\s*)<activity#/>\
        <activity#gms' "$ANDROID_MANIFEST"

grep -n "com.google.android.gms.ads.APPLICATION_ID" "$ANDROID_MANIFEST" || true
