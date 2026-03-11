#!/usr/bin/env bash
# Terminal: kitty, tmux, zsh

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_terminal() {
    log_info "Installing terminal packages..."

    case "$OS" in
        debian) pkg_install kitty tmux zsh ;;
        fedora) pkg_install kitty tmux zsh ;;
        arch) pkg_install kitty tmux zsh ;;
    esac

    log_success "Terminal packages installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_terminal || true
