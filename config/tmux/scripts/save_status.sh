#!/usr/bin/env bash

resurrect_ts=$(stat -c %Y "$HOME/.local/share/tmux/resurrect/last" 2>/dev/null)

format_elapsed() {
    local ts=$1
    local elapsed=$(( $(date +%s) - ts ))
    if [ $elapsed -lt 60 ]; then
        echo "just now"
    elif [ $elapsed -lt 3600 ]; then
        echo "$(( elapsed / 60 ))m ago"
    elif [ $elapsed -lt 86400 ]; then
        echo "$(( elapsed / 3600 ))h ago"
    else
        echo "$(( elapsed / 86400 ))d ago"
    fi
}

if [ -z "$resurrect_ts" ]; then
    echo "nothing to resurrect"
else
    echo "resurrect saved $(format_elapsed $resurrect_ts)"
fi