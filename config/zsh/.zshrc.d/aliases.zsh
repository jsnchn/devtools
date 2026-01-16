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

function devtools-sync {
  (
    cd ~/.devtools || exit 1

    # Push local changes if any
    if [[ -n $(git status --porcelain) ]]; then
      echo "[sync] Pushing local changes..."
      git add -A
      git commit -m "update devtools"
      git push
    fi

    # Pull remote changes if any
    git fetch origin
    local behind
    behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
    if [[ "$behind" != "0" ]]; then
      echo "[sync] Pulling $behind commit(s)..."
      git pull --rebase
      echo "[sync] Running install..."
      ./install.sh
    else
      echo "[sync] Already up to date."
    fi
  )
}
