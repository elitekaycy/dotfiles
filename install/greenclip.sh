#!/usr/bin/env bash
# Greenclip clipboard manager

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_greenclip() {
    if has greenclip; then
        log_success "Greenclip already installed"
        return
    fi

    log_info "Installing Greenclip..."

    local greenclip_url="https://github.com/erebe/greenclip/releases/download/v4.2/greenclip"
    mkdir -p "$HOME/.local/bin"
    curl -Lo "$HOME/.local/bin/greenclip" "$greenclip_url"
    chmod +x "$HOME/.local/bin/greenclip"

    mkdir -p "$HOME/.config/greenclip"

    log_success "Greenclip installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_greenclip || true
