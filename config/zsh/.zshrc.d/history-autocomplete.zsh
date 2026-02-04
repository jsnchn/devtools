autoload -U history-search-start
zle -N history-search-start

bindkey '^I' history-search-start
