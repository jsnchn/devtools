#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

send_warning() {
    local error_msg="$1"
    local app_token="${PUSHOVER_APP_TOKEN:-YOUR_APP_TOKEN}"
    local user_key="${PUSHOVER_USER_KEY:-YOUR_USER_KEY}"
    
    curl -s \
        --form-string "token=${app_token}" \
        --form-string "user=${user_key}" \
        --form-string "title=Pushover System Alert" \
        --form-string "message=Failed to send notification: ${error_msg}" \
        --form-string "priority=1" \
        https://api.pushover.net/1/messages.json >/dev/null 2>&1 || true
}

if [[ -f "$HOME/.pushover.env" ]]; then
    source "$HOME/.pushover.env"
fi

APP_TOKEN="${PUSHOVER_APP_TOKEN:-YOUR_APP_TOKEN}"
USER_KEY="${PUSHOVER_USER_KEY:-YOUR_USER_KEY}"

TITLE="${1:-}"
MESSAGE="${2:-}"
URL="${3:-}"
URL_TITLE="${4:-}"
PRIORITY="${5:-0}"

if [[ -z "$TITLE" ]] || [[ -z "$MESSAGE" ]]; then
    echo "Usage: $SCRIPT_NAME \"title\" \"message\" [url] [url_title] [priority]" >&2
    echo "Priority: -1=low, 0=normal, 1=high" >&2
    exit 1
fi

CURL_ARGS=(
    -s
    --form-string "token=${APP_TOKEN}"
    --form-string "user=${USER_KEY}"
    --form-string "title=${TITLE}"
    --form-string "message=${MESSAGE}"
    --form-string "priority=${PRIORITY}"
)

if [[ -n "$URL" ]]; then
    CURL_ARGS+=(--form-string "url=${URL}")
fi

if [[ -n "$URL_TITLE" ]]; then
    CURL_ARGS+=(--form-string "url_title=${URL_TITLE}")
fi

if ! curl "${CURL_ARGS[@]}" https://api.pushover.net/1/messages.json >/dev/null 2>&1; then
    send_warning "curl failed - check network and credentials"
    exit 1
fi
