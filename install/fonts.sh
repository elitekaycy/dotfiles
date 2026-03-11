#!/usr/bin/env bash
# Nerd Fonts installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_fonts() {
    local font_dir="$HOME/.local/share/fonts"

    if fc-list | grep -qi "JetBrains"; then
        log_success "JetBrains Mono Nerd Font already installed"
        return
    fi

    log_info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$font_dir"

    local version="v3.1.1"
    curl -Lo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d "$font_dir"
    rm /tmp/JetBrainsMono.zip

    fc-cache -fv
    log_success "Fonts installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_fonts || true
