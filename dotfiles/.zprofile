# Set up the initial PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"

# Source .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc"
fi