#!/usr/bin/env bash
# Development tools - all managed by mise
# See mise/.config/mise/config.toml for the full list

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_devtools() {
    if ! has mise; then
        log_error "mise not installed. Run ./install.sh zsh first."
        return 1
    fi

    log_info "Installing dev tools via mise..."
    mise install
    log_success "Dev tools installed via mise"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_devtools || true
