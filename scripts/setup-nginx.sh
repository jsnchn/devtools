#!/bin/bash
set -euo pipefail

DEVTOOLS_DIR="${DEVTOOLS_DIR:-$HOME/.devtools}"

info() { echo "[INFO] $1"; }
error() { echo "[ERROR] $1" >&2; exit 1; }

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        error "This script requires sudo access. Please run with sudo or provide password when prompted."
    fi
}

install_ttyd() {
    if command -v ttyd &>/dev/null; then
        info "ttyd is already installed"
        return
    fi

    info "Installing ttyd..."
    sudo apt-get update
    sudo apt-get install -y ttyd
}

setup_nginx() {
    local nginx_config="$DEVTOOLS_DIR/config/nginx/tmux-proxy.conf"
    local sites_available="/etc/nginx/sites-available"
    local sites_enabled="/etc/nginx/sites-enabled"
    local config_name="tmux-proxy"

    if [[ ! -f "$nginx_config" ]]; then
        error "Nginx config not found: $nginx_config"
    fi

    info "Setting up nginx configuration..."

    # Create symlink in sites-available
    if [[ ! -L "$sites_available/$config_name" ]]; then
        sudo ln -sf "$nginx_config" "$sites_available/$config_name"
        info "Created symlink: $sites_available/$config_name"
    else
        info "Symlink already exists: $sites_available/$config_name"
    fi

    # Enable site in sites-enabled
    if [[ ! -L "$sites_enabled/$config_name" ]]; then
        sudo ln -sf "$sites_available/$config_name" "$sites_enabled/$config_name"
        info "Enabled site: $config_name"
    else
        info "Site already enabled: $config_name"
    fi

    # Test nginx configuration
    info "Testing nginx configuration..."
    if ! sudo nginx -t; then
        error "Nginx configuration test failed"
    fi

    # Reload nginx
    info "Reloading nginx..."
    sudo systemctl reload nginx || sudo nginx

    info "Nginx configuration complete!"
}

setup_ttyd_service() {
    local systemd_user_dir="$DEVTOOLS_DIR/config/systemd/user"
    local systemd_dir="$HOME/.config/systemd"
    local service_file="ttyd.service"

    if [[ ! -f "$systemd_user_dir/$service_file" ]]; then
        error "Systemd service not found: $systemd_user_dir/$service_file"
    fi

    info "Setting up ttyd systemd service..."

    # Create user systemd directory
    mkdir -p "$systemd_dir/user"

    # Link service file
    if [[ ! -L "$systemd_dir/user/$service_file" ]]; then
        ln -sf "$systemd_user_dir/$service_file" "$systemd_dir/user/$service_file"
        info "Created symlink: $systemd_dir/user/$service_file"
    else
        info "Symlink already exists: $systemd_dir/user/$service_file"
    fi

    # Reload systemd daemon
    systemctl --user daemon-reload

    # Enable and start service
    if systemctl --user is-enabled "$service_file" &>/dev/null; then
        info "Service already enabled: $service_file"
    else
        systemctl --user enable "$service_file"
        info "Enabled service: $service_file"
    fi

    info "Starting ttyd service..."
    if systemctl --user start "$service_file"; then
        info "Started ttyd service"
    else
        error "Failed to start ttyd service"
    fi

    info "ttyd service setup complete!"
}

main() {
    echo ""
    echo "======================================"
    echo "       Setting up Nginx & ttyd        "
    echo "======================================"
    echo ""

    check_sudo

    install_ttyd
    setup_nginx
    setup_ttyd_service

    echo ""
    echo "======================================"
    echo "       Setup Complete!                 "
    echo "======================================"
    echo ""
    info "ttyd should be accessible at: http://localhost:7681"
    info "Nginx proxy should be accessible at: http://localhost/tmux/"
    info "Via Tailscale: https://$(hostname).tailscale.net/tmux/"
}

main "$@"
