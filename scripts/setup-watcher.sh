#!/bin/bash
set -euo pipefail

# Setup devtools watcher service

DEVTOOLS_DIR="${HOME}/.devtools"

info() { echo "[INFO] $1"; }

setup_macos() {
  local plist_path="$HOME/Library/LaunchAgents/com.devtools.watch.plist"
  mkdir -p "$HOME/Library/LaunchAgents"

  cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.devtools.watch</string>
  <key>ProgramArguments</key>
  <array>
    <string>${DEVTOOLS_DIR}/scripts/devtools-watch.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${HOME}/.devtools-watch.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.devtools-watch.log</string>
</dict>
</plist>
EOF

  launchctl unload "$plist_path" 2>/dev/null || true
  launchctl load "$plist_path"
  info "Devtools watcher started (launchd)"
}

setup_linux() {
  local service_dir="$HOME/.config/systemd/user"
  local service_path="$service_dir/devtools-watch.service"
  mkdir -p "$service_dir"

  cat > "$service_path" << EOF
[Unit]
Description=Devtools Watcher
After=syncthing.service

[Service]
ExecStart=${DEVTOOLS_DIR}/scripts/devtools-watch.sh
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable devtools-watch
  systemctl --user restart devtools-watch
  info "Devtools watcher started (systemd)"
}

main() {
  case "$(uname -s)" in
    Darwin) setup_macos ;;
    Linux)  setup_linux ;;
    *)      echo "Unsupported OS"; exit 1 ;;
  esac
}

main
