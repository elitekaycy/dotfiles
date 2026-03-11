#!/usr/bin/env bash
# Rust / Cargo installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_rust() {
    if has rustc; then
        log_success "Rust already installed"
        return
    fi

    log_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    log_success "Rust installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_rust || true
