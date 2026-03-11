#!/usr/bin/env bash
# Neovim - managed by mise
# See mise/.config/mise/config.toml

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_neovim() {
    if has nvim; then
        log_success "Neovim already installed ($(nvim --version | head -1))"
        return
    fi

    if ! has mise; then
        log_error "mise not installed. Run ./install.sh zsh first."
        return 1
    fi

    log_info "Installing Neovim via mise..."
    mise install neovim
    log_success "Neovim installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_neovim || true
