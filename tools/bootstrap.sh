#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash tools/set_admob_ids.sh

flutter pub get

if [ -d ios ]; then
  cd ios
  if command -v pod >/dev/null 2>&1; then
    pod repo update
    pod install --repo-update
  fi
  cd "$ROOT_DIR"
fi
