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

# Set default editor
export EDITOR="hx"
export VISUAL="hx"

# History search with arrow keys (terminal-agnostic)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind both normal mode and application mode sequences
bindkey "${terminfo[kcuu1]:-^[[A}" up-line-or-beginning-search
bindkey "${terminfo[kcud1]:-^[[B}" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Source modular configurations
if [[ -d "$DEVTOOLS_DIR/config/zsh/.zshrc.d" ]]; then
  for config in "$DEVTOOLS_DIR/config/zsh/.zshrc.d"/*.zsh; do
    [[ -r "$config" ]] && source "$config"
  done
fi

# Source platform-specific config
case "$(uname -s)" in
  Darwin)
    [[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/macos.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/macos.zsh"
    ;;
  Linux)
    [[ -r "$DEVTOOLS_DIR/config/zsh/.zshrc.d/linux.zsh" ]] && source "$DEVTOOLS_DIR/config/zsh/.zshrc.d/linux.zsh"
    ;;
esac

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
