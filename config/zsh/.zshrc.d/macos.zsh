# macOS-specific configuration

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ZPlug
if [[ -n "$HOMEBREW_PREFIX" ]] && [[ -d "$HOMEBREW_PREFIX/opt/zplug" ]]; then
  export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
  source "$ZPLUG_HOME/init.zsh"
fi

# rbenv (for older Ruby versions)
if [[ -d "$HOME/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - zsh)"
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
  export LDFLAGS="-L/opt/homebrew/opt/readline/lib:$LDFLAGS"
  export CPPFLAGS="-I/opt/homebrew/opt/readline/include:$CPPFLAGS"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig:$PKG_CONFIG_PATH"
  export optflags="-Wno-error=implicit-function-declaration"
  export LDFLAGS="-L/opt/homebrew/opt/libffi/lib:$LDFLAGS"
  export CPPFLAGS="-I/opt/homebrew/opt/libffi/include:$CPPFLAGS"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# pnpm (macOS path)
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# JetBrains Toolbox
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Antigravity
if [[ -d "$HOME/.antigravity" ]]; then
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi

# WezTerm
if [[ -d "/Applications/WezTerm.app" ]]; then
  export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
fi

# OrbStack
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null

# Sublime Text
if [[ -d "/Applications/Sublime Text.app" ]]; then
  export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
fi

# macOS ls colors
alias ls="ls -G"

# fzf from Homebrew
if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi
