#!/usr/bin/env bash
# Development tools: bat, fd, fzf, eza, ripgrep, btop

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_devtools() {
    log_info "Installing development tools..."

    case "$OS" in
        debian)
            pkg_install bat fd-find fzf ripgrep btop
            # eza needs special install on debian
            if ! has eza; then
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt-get update
                pkg_install eza
            fi
            ;;
        fedora)
            pkg_install bat fd-find fzf ripgrep eza btop
            ;;
        arch)
            pkg_install bat fd fzf ripgrep eza btop
            ;;
    esac

    log_success "Development tools installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_devtools || true
