#!/bin/bash
set -euo pipefail

# Merge opencode config template with local config
# Usage: merge-opencode-config.sh <template.json> <local.json> <output.json>

TEMPLATE_FILE="${1:-}"
LOCAL_FILE="${2:-}"
OUTPUT_FILE="${3:-}"

error() { echo "[ERROR] $1" >&2; exit 1; }
info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

if [[ -z "$TEMPLATE_FILE" ]] || [[ -z "$LOCAL_FILE" ]] || [[ -z "$OUTPUT_FILE" ]]; then
    error "Usage: $0 <template.json> <local.json> <output.json>"
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    error "Template file not found: $TEMPLATE_FILE"
fi

if [[ ! -f "$LOCAL_FILE" ]]; then
    warn "Local config not found: $LOCAL_FILE"
    warn "Creating local config from template..."
    cp "$TEMPLATE_FILE" "$LOCAL_FILE"
    LOCAL_FILE="$TEMPLATE_FILE"
fi

# Create backup of existing output file
if [[ -f "$OUTPUT_FILE" ]]; then
    BACKUP_FILE="${OUTPUT_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
    info "Backed up existing config to: $BACKUP_FILE"
fi

# Perform deep merge using jq (local overrides template)
# jq -s merges arrays, we use object merge: . * .2
jq -s 'def deep_merge: .[0] * .[1]; deep_merge' "$TEMPLATE_FILE" "$LOCAL_FILE" > "$OUTPUT_FILE"

info "Merged config written to: $OUTPUT_FILE"
