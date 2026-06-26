#!/usr/bin/env bash
set -Eeuo pipefail

readonly PROJECT_ID="flow-ai-656b3"
readonly FIREBASE_TOOLS_VERSION="15.10.1"
readonly MODE="${FLOW_AI_HOSTING_MODE:?missing mode}"
readonly CHANNEL="${FLOW_AI_HOSTING_CHANNEL:-}"

run() {
  if [ "${FLOW_AI_HOSTING_DRY_RUN:-0}" = "1" ]; then
    printf 'DRY_RUN_COMMAND='
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

case "$MODE" in
  live)
    [ -z "$CHANNEL" ] || exit 64
    run npx --yes "firebase-tools@${FIREBASE_TOOLS_VERSION}" \
      deploy \
      --only hosting \
      --project "$PROJECT_ID" \
      --non-interactive
    ;;
  preview)
    [[ "$CHANNEL" =~ ^pr-[0-9]+$ ]] || exit 64
    run npx --yes "firebase-tools@${FIREBASE_TOOLS_VERSION}" \
      hosting:channel:deploy "$CHANNEL" \
      --expires 7d \
      --project "$PROJECT_ID" \
      --non-interactive
    ;;
  *)
    exit 64
    ;;
esac
