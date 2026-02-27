#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PBXPROJ="$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj"

OLD_APP_ID="com.flowai.flowAi"
NEW_APP_ID="com.flowai.health"

perl -0pi -e "s/PRODUCT_BUNDLE_IDENTIFIER = \\Q$OLD_APP_ID\\E;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_APP_ID;/g" "$PBXPROJ"
perl -0pi -e "s/PRODUCT_BUNDLE_IDENTIFIER = \\Q$OLD_APP_ID\\E\\.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_APP_ID.RunnerTests;/g" "$PBXPROJ"

grep -n "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ" | head -n 40
