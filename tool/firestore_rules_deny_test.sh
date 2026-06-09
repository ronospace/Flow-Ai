#!/usr/bin/env bash
set -euo pipefail
BASE="http://${FIRESTORE_EMULATOR_HOST}/v1/projects/demo-flow-ai/databases/(default)/documents"
TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_BODY"' EXIT

expect_denied() {
  local name="$1"
  shift
  local status
  status="$(curl -sS -o "$TMP_BODY" -w "%{http_code}" "$@")"
  printf "%s_status=%s\n" "$name" "$status"
  [[ "$status" == "403" ]]
}

expect_denied invite_read "$BASE/partnerInvites/rules-test"
expect_denied connection_read "$BASE/partnerConnections/rules-test"
expect_denied invite_write -X PATCH -H "Content-Type: application/json" --data '{"fields":{"ownerUid":{"stringValue":"unauthorized"}}}' "$BASE/partnerInvites/rules-test"
expect_denied connection_write -X PATCH -H "Content-Type: application/json" --data '{"fields":{"userId1":{"stringValue":"unauthorized"}}}' "$BASE/partnerConnections/rules-test"

printf "firestore_deny_by_default_contract=PASS\n"
