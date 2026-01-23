# Linux-specific configuration

# Auto-attach to tmux on SSH login
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
	tmux attach-session -t main 2>/dev/null || tmux new-session -s main
fi

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

# fzf shell integration (completion and key-bindings)
if [[ -f "$HOME/.fzf/shell/completion.zsh" ]]; then
	source "$HOME/.fzf/shell/completion.zsh"
fi
if [[ -f "$HOME/.fzf/shell/key-bindings.zsh" ]]; then
	source "$HOME/.fzf/shell/key-bindings.zsh"
fi
