# zprofile - runs before .zshrc on login shells

# Set up initial PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/.local/bin:$PATH"

# Source .zshrc
[[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
