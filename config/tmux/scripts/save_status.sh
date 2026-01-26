#!/usr/bin/env bash

continuum_ts=$(tmux show-option -gqv "@continuum-save-last-timestamp" 2>/dev/null)
resurrect_ts=$(stat -c %Y "$HOME/.tmux/resurrect/last" 2>/dev/null)

if [ -z "$continuum_ts" ] && [ -z "$resurrect_ts" ]; then
    echo "#[bg=#000000,fg=#808080]no data#[default]"
elif [ -z "$resurrect_ts" ] || ([ -n "$continuum_ts" ] && [ "$continuum_ts" -gt "$resurrect_ts" ]); then
    elapsed=$(( $(date +%s) - continuum_ts ))
    if [ $elapsed -lt 60 ]; then
        relative="just now"
    elif [ $elapsed -lt 3600 ]; then
        relative="${(( elapsed / 60 ))}m ago"
    elif [ $elapsed -lt 86400 ]; then
        relative="${(( elapsed / 3600 ))}h ago"
    else
        relative="${(( elapsed / 86400 ))}d ago"
    fi
    echo "#[bg=#000000,fg=#808080]${relative}#[default]"
else
    elapsed=$(( $(date +%s) - resurrect_ts ))
    if [ $elapsed -lt 60 ]; then
        relative="just now"
    elif [ $elapsed -lt 3600 ]; then
        relative="${(( elapsed / 60 ))}m ago"
    elif [ $elapsed -lt 86400 ]; then
        relative="${(( elapsed / 3600 ))}h ago"
    else
        relative="${(( elapsed / 86400 ))}d ago"
    fi
    echo "#[bg=#808080,fg=#000000]${relative}#[default]"
fi