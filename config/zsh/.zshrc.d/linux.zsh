# Linux-specific configuration

# Linux ls colors
alias ls="ls --color=auto"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# fzf from git install
export PATH="$HOME/.fzf/bin:$PATH"
