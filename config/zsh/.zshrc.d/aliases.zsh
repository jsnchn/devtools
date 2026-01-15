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
devtools-down() {
  cd ~/.devtools
  git fetch origin
  local status
  status=$(git rev-list --count --right-only HEAD..origin/main 2>/dev/null || echo "0")
  if [[ "$status" == "0" ]]; then
    echo "Already up to date."
  else
    git pull && ./install.sh
  fi
}
