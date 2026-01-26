#!/usr/bin/env bash

continuum_ts=$(tmux show-option -gqv "@continuum-save-last-timestamp" 2>/dev/null)
resurrect_ts=$(stat -c %Y "$HOME/.tmux/resurrect/last" 2>/dev/null)

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

if [ -z "$continuum_ts" ] && [ -z "$resurrect_ts" ]; then
    echo "nothing to resurrect"
elif [ -z "$resurrect_ts" ] || ([ -n "$continuum_ts" ] && [ "$continuum_ts" -gt "$resurrect_ts" ]); then
    echo "C $(format_elapsed $continuum_ts)"
else
    echo "$(format_elapsed $resurrect_ts)"
fi