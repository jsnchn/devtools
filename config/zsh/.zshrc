# Main zsh configuration
# Sources modular configs from .zshrc.d/

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Devtools location
export DEVTOOLS_DIR="${DEVTOOLS_DIR:-$HOME/.devtools}"

# Base PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Set default editor
export EDITOR="hx"
export VISUAL="hx"

# Source platform-specific config
case "$(uname -s)" in
  Darwin)
    [[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/macos.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/macos.zsh"
    ;;
  Linux)
    [[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/linux.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/linux.zsh"
    ;;
esac

# Source common configs
[[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/prompt.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/prompt.zsh"
[[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/aliases.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/aliases.zsh"

# direnv
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# mise (version manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
elif [[ -f "$HOME/.local/bin/mise" ]]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# History search with arrow keys (terminal-agnostic)
# Loaded last to ensure it takes precedence over fzf bindings
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind both normal mode (^[[A) and application mode (^[OA) sequences
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jasonchen/.lmstudio/bin"
# End of LM Studio CLI section

