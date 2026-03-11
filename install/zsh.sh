#!/usr/bin/env bash
# Zsh ecosystem: Oh My Zsh, asdf, atuin

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh already installed"
        return
    fi

    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed"
}

install_asdf() {
    if [[ -d "$HOME/.asdf" ]]; then
        log_success "asdf already installed"
        return
    fi

    log_info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    log_success "asdf installed"
}

install_atuin() {
    if has atuin; then
        log_success "Atuin already installed"
        return
    fi

    log_info "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    log_success "Atuin installed"
}

set_zsh_default() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "Zsh is already default shell"
        return
    fi

    log_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Zsh set as default (restart terminal to apply)"
}

install_zsh_ecosystem() {
    install_ohmyzsh
    install_asdf
    install_atuin
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_zsh_ecosystem || true
