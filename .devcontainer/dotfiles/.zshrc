# Add paths for installed tools
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

###
# Git 
###

# Autoload zsh add-zsh-hook and vcs_info functions
autoload -Uz add-zsh-hook vcs_info

# Enable substitution in the prompt
setopt prompt_subst

# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_info

# Multi-line prompt: first line is path & Git info, second line is prompt indicator
PROMPT='%F{blue}%~%f %F{magenta}${vcs_info_msg_0_}%f
%F{yellow}% ❯ %f'

# Optional: right prompt with time
RPROMPT='%F{yellow}[%D{%L:%M:%S}]%f'

# Enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true

# Custom strings for unstaged (*) and staged (+) changes
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'

# Format for Git info
zstyle ':vcs_info:git:*' formats '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'

# Case-insensitive with smart-case tab completion.  Only case sensitive if uppercase is used.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=* l:|=*'

###
# direnv
###
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# pnpm
export PNPM_HOME="/home/jsnchn/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Go
export GOPATH=$HOME/go
export PATH=$PATH:/home/jsnchn/go/bin
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

###
# Aliases
###
alias ll="ls -al"
alias lzg="lazygit"
alias lzd="lazydocker"
alias lt="npx localtunnel --subdomain jsnchn --port"
alias air="~/go/bin/air"

###
# mise-en-place
###
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

###
# fzf
###
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

