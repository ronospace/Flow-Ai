#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
  pwd -P
)"

cd "$ROOT"

hash_file() {
  python3 - "$1" <<'PYHASH'
from pathlib import Path
import hashlib
import sys

print(
    hashlib.sha256(
        Path(sys.argv[1]).read_bytes()
    ).hexdigest()
)
PYHASH
}

NODE_MAJOR="$(
  node -p "process.versions.node.split('.')[0]"
)"

test "$NODE_MAJOR" = "24" || {
  echo "EXPECTED_NODE_MAJOR=24"
  echo "ACTUAL_NODE_MAJOR=$NODE_MAJOR"
  exit 1
}

FLUTTER_VERSION="$(
  flutter --version --machine |
  python3 -c '
import json
import sys

print(json.load(sys.stdin)["frameworkVersion"])
'
)"

test "$FLUTTER_VERSION" = "3.44.6" || {
  echo "EXPECTED_FLUTTER_VERSION=3.44.6"
  echo "ACTUAL_FLUTTER_VERSION=$FLUTTER_VERSION"
  exit 1
}

PUBSPEC_LOCK_BEFORE="$(hash_file pubspec.lock)"

flutter pub get

PUBSPEC_LOCK_AFTER="$(hash_file pubspec.lock)"

test "$PUBSPEC_LOCK_BEFORE" = "$PUBSPEC_LOCK_AFTER" || {
  echo "PUBSPEC_LOCK_CHANGED_DURING_VALIDATION=true"
  exit 1
}

flutter analyze \
  --fatal-warnings \
  --fatal-infos

python3 - "$ROOT" "$(command -v flutter)" <<'PYTEST'
from pathlib import Path
import subprocess
import sys

root = Path(sys.argv[1])
flutter = sys.argv[2]

tests = sorted(
    path.relative_to(root).as_posix()
    for path in (root / "test").rglob("*_test.dart")
    if not path.relative_to(root).as_posix().startswith(
        "test/_legacy_disabled/"
    )
)

if len(tests) != 82:
    raise SystemExit(
        "ACTIVE_FLUTTER_TEST_FILE_COUNT_MISMATCH:"
        f"{len(tests)}"
    )

print("ACTIVE_FLUTTER_TEST_FILE_COUNT=82")

completed = subprocess.run(
    [
        flutter,
        "test",
        "--no-pub",
        "--reporter=compact",
        *tests,
    ],
    cwd=root,
    check=False,
)

raise SystemExit(completed.returncode)
PYTEST

(
  cd functions

  FUNCTIONS_LOCK_BEFORE="$(
    hash_file package-lock.json
  )"

  npm ci \
    --engine-strict \
    --no-audit \
    --no-fund

  FUNCTIONS_LOCK_AFTER="$(
    hash_file package-lock.json
  )"

  test "$FUNCTIONS_LOCK_BEFORE" = "$FUNCTIONS_LOCK_AFTER" || {
    echo "FUNCTIONS_PACKAGE_LOCK_CHANGED_DURING_VALIDATION=true"
    exit 1
  }

  npm run build
  npm run verify
  npm run lint
  npm test
)

flutter build web \
  --release \
  --no-pub

echo "UNIFIED_RELEASE_VALIDATION_STATUS=PASS"
