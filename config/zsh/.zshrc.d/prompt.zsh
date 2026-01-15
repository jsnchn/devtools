# Git-aware prompt configuration

# Autoload zsh add-zsh-hook and vcs_info functions
autoload -Uz add-zsh-hook vcs_info

# Enable substitution in the prompt
setopt prompt_subst

# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_info

# Multi-line prompt: first line is path & Git info, second line is prompt indicator
PROMPT='%F{blue}%~%f %F{magenta}${vcs_info_msg_0_}%f
%F{yellow}% ❯ %f'

# Right prompt with time
RPROMPT='%F{yellow}[%D{%L:%M:%S}]%f'

# Enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true

# Custom strings for unstaged (*) and staged (+) changes
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'

# Format for Git info
zstyle ':vcs_info:git:*' formats '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'

# Case-insensitive with smart-case tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=* l:|=*'
