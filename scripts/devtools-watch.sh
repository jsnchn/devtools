#!/bin/bash
set -euo pipefail

# Watch for changes to devtools and auto-install
# Runs in background, triggered by Syncthing file changes

DEVTOOLS_DIR="${HOME}/.devtools"
STATE_FILE="${HOME}/.devtools-watch-state"
CHECK_INTERVAL=30  # seconds

log() { echo "[devtools-watch] $(date '+%H:%M:%S') $1"; }

get_state() {
  # Get a hash of files that would trigger an install
  find "$DEVTOOLS_DIR/scripts" "$DEVTOOLS_DIR/config" -type f 2>/dev/null | \
    xargs stat -f '%m %N' 2>/dev/null || \
    xargs stat -c '%Y %n' 2>/dev/null | \
    md5sum | cut -d' ' -f1
}

run_install() {
  log "Changes detected, running install..."
  cd "$DEVTOOLS_DIR"
  ./install.sh
  log "Install complete"
}

main() {
  log "Starting devtools watcher (checking every ${CHECK_INTERVAL}s)"

  # Initialize state
  local current_state
  current_state=$(get_state)
  echo "$current_state" > "$STATE_FILE"

  while true; do
    sleep "$CHECK_INTERVAL"

    local new_state
    new_state=$(get_state)
    local old_state
    old_state=$(cat "$STATE_FILE" 2>/dev/null || echo "")

    if [[ "$new_state" != "$old_state" ]]; then
      run_install
      echo "$new_state" > "$STATE_FILE"
    fi
  done
}

main
