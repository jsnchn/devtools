# Shell aliases

alias ll="ls -al"
alias lzg="lazygit"
alias lzd="lazydocker"
alias opencode="opencode upgrade && opencode"

# Tailscale CLI (macOS uses app bundle, Linux has it in PATH)
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# Devtools management
alias devtools="cd ~/.devtools"
alias devtools-up="(cd ~/.devtools && git add -A && git commit -m 'update configs' && git push)"
alias devtools-down="(cd ~/.devtools && git pull && ./install.sh)"
