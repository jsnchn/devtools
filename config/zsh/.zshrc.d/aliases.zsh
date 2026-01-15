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
alias devtools-up="(cd ~/.devtools && git add -A -- ':!config/opencode/config.local.json' && git commit -m 'update configs' && git push --force)"
devtools-down() {
  cd ~/.devtools
  git fetch origin
  local status
  status=$(git rev-list --count --right-only HEAD..origin/main 2>/dev/null || echo "0")

  if [[ "$status" == "0" ]]; then
    echo "Already up to date."
    return
  fi

  # Backup current merged configs
  BACKUP_DIR="$HOME/.devtools-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -r ~/.config/opencode/* "$BACKUP_DIR/" 2>/dev/null || true

  # Show what changed in templates
  echo ""
  echo "Changes in opencode config template:"
  git diff HEAD..origin/main -- config/opencode/config.json.template || echo "No template changes"

  echo ""
  read -p "Proceed with update? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git pull && ./install.sh
    echo "Configs backed up to: $BACKUP_DIR"
  else
    echo "Update cancelled."
  fi
}
