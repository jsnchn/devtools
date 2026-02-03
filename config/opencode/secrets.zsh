#!/bin/bash
set -euo pipefail

# Load secrets from devtools directory as environment variables
# These are synced via Syncthing

DEVTOOLS_DIR="${DEVTOOLS_DIR:-$HOME/.devtools}"
SECRETS_DIR="$DEVTOOLS_DIR/config/secrets"

# OpenRouter API Key
if [[ -f "$SECRETS_DIR/openrouter-api-key" ]]; then
  export OPENROUTER_API_KEY=$(sed 's/#.*//; /^$/d' "$SECRETS_DIR/openrouter-api-key" | tr -d '\n')
fi

# Context7 API Key
if [[ -f "$SECRETS_DIR/context7-api-key" ]]; then
  export CONTEXT7_API_KEY=$(sed 's/#.*//; /^$/d' "$SECRETS_DIR/context7-api-key" | tr -d '\n')
fi