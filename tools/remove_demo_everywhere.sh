#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

git add -A >/dev/null 2>&1 || true
git commit -m "checkpoint before removing demo" >/dev/null 2>&1 || true

mkdir -p _dev_backups
find lib -maxdepth 4 -type f \( -name "*.bak" -o -name "*.bak*" -o -name "*.demooff.*" -o -name "*.nodemo.*" \) -print0 | while IFS= read -r -d '' f; do
  mv "$f" "_dev_backups/$(basename "$f")" || true
done

if ! grep -q "^_dev_backups/$" .gitignore 2>/dev/null; then
  printf "\n_dev_backups/\n" >> .gitignore
fi

if [ -f lib/core/services/demo_data_service.dart ]; then
  mv lib/core/services/demo_data_service.dart lib/core/services/demo_data_service.dart.disabled
fi

grep -RIl "demo_data_service.dart" lib 2>/dev/null | while read -r f; do
  perl -0pi -e "s/^.*demo_data_service\\.dart.*\\n//mg" "$f"
done

perl -0777 -pi -e '
s/\n\s*const demoEmail\s*=\s*'\''demo\@flowai\.app'\'';.*?\n\s*\}\s*catch\s*\(e\)\s*\{\s*\n\s*debugPrint\([^\)]*\);\s*\n\s*return AuthResult\.failure\([^\)]*\);\s*\n\s*\}\s*\n\s*\}/\n/s
' lib/core/services/auth_service.dart 2>/dev/null || true

perl -0pi -e "s/email\\s*==\\s*demoEmail\\s*\\?\\s*'demo'\\s*:\\s*'local'/'local'/g" lib/core/services/auth_service.dart 2>/dev/null || true
perl -0pi -e "s/email\\s*==\\s*demoEmail\\s*\\?\\s*'demo'\\s*:\\s*'local'/'local'/g" lib/core/services/auth_service.dart 2>/dev/null || true

perl -0777 -pi -e '
s/(Future<AuthResult>\s+signInWithEmail\(\{\s*required String email,\s*required String password,\s*\}\)\s+async\s*\{\s*try\s*\{\s*)/$1\n      if (email.trim().toLowerCase() == \"demo\@flowai.app\") {\n        return AuthResult.failure(\"Demo account disabled\");\n      }\n/s
' lib/core/services/auth_service.dart 2>/dev/null || true

perl -0pi -e 's/^.*Demo credentials: demo\@flowai\.app.*\n//mg' lib/core/services/local_user_service.dart 2>/dev/null || true
perl -0pi -e 's/^.*demo\@flowai\.app.*\n//mg' lib/core/services/local_user_service.dart 2>/dev/null || true
perl -0pi -e 's/^.*FlowAiDemo2025!.*\n//mg' lib/core/services/local_user_service.dart 2>/dev/null || true
perl -0pi -e 's/demo_user/demo_user_removed/g' lib/core/services/local_user_service.dart 2>/dev/null || true

perl -0pi -e 's/^.*demo\@flowai\.app.*\n//mg' lib/features/auth/screens/auth_screen.dart 2>/dev/null || true
perl -0pi -e 's/^.*FlowAiDemo2025!.*\n//mg' lib/features/auth/screens/auth_screen.dart 2>/dev/null || true
perl -0pi -e 's/^.*demo_user.*\n//mg' lib/features/auth/screens/auth_screen.dart 2>/dev/null || true

perl -0pi -e 's/^.*demo\@flowai\.app.*\n//mg' lib/features/auth/screens/futuristic_auth_screen.dart 2>/dev/null || true
perl -0pi -e 's/^.*FlowAiDemo2025!.*\n//mg' lib/features/auth/screens/futuristic_auth_screen.dart 2>/dev/null || true
perl -0pi -e 's/^.*demo_user.*\n//mg' lib/features/auth/screens/futuristic_auth_screen.dart 2>/dev/null || true

perl -0pi -e 's/demo_user_id/anonymous_user/g' lib/features/ai_predictions/screens/ai_predictions_screen.dart 2>/dev/null || true
perl -0pi -e 's/demo_user/anonymous_user/g' lib/features/health/screens/real_time_health_dashboard.dart 2>/dev/null || true

grep -RIn "demo@flowai\.app|FlowAiDemo2025|demo_user_id|provider': 'demo'|demo_data_service" lib || true

dart analyze lib/core/services/auth_service.dart >/dev/null 2>&1 || true
