#!/usr/bin/env bash
set -euo pipefail

APP_TOKEN="${PUSHOVER_APP_TOKEN:-YOUR_APP_TOKEN}"
USER_KEY="${PUSHOVER_USER_KEY:-YOUR_USER_KEY}"

TITLE="$1"
MESSAGE="$2"
MACHINE="$(hostname)"

curl -s \
  --form-string "token=${APP_TOKEN}" \
  --form-string "user=${USER_KEY}" \
  --form-string "title=${TITLE} (${MACHINE})" \
  --form-string "message=${MESSAGE}" \
  https://api.pushover.net/1/messages.json >/dev/null