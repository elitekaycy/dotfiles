#!/usr/bin/env bash
# Neovim installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_neovim() {
    log_info "Installing Neovim..."

    case "$OS" in
        debian)
            # Ubuntu/Debian repos have old nvim, use AppImage
            if ! has nvim || [[ $(nvim --version | head -1 | grep -oP '\d+\.\d+' | head -1) < "0.9" ]]; then
                log_info "Installing latest Neovim via AppImage..."
                curl -Lo /tmp/nvim.appimage "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
                chmod +x /tmp/nvim.appimage
                sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
            fi
            ;;
        fedora)
            pkg_install neovim
            ;;
        arch)
            pkg_install neovim
            ;;
    esac

    log_success "Neovim installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_neovim || true
