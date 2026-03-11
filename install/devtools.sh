#!/usr/bin/env bash
# Development tools: bat, fd, fzf, eza, ripgrep, btop

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_devtools() {
    log_info "Installing development tools..."

    case "$OS" in
        debian)
            pkg_install bat fd-find fzf ripgrep btop jq
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
            pkg_install bat fd-find fzf ripgrep eza btop jq
            ;;
        arch)
            pkg_install bat fd fzf ripgrep eza btop jq
            ;;
    esac

    log_success "Development tools installed"
}

install_gh() {
    if has gh; then
        log_success "GitHub CLI already installed"
        return
    fi

    log_info "Installing GitHub CLI..."

    case "$OS" in
        debian)
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update
            pkg_install gh
            ;;
        fedora)
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            pkg_install gh
            ;;
        arch)
            pkg_install github-cli
            ;;
    esac

    log_success "GitHub CLI installed"
}

install_lazygit() {
    if has lazygit; then
        log_success "lazygit already installed"
        return
    fi

    log_info "Installing lazygit..."

    case "$OS" in
        debian)
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit /usr/local/bin
            rm /tmp/lazygit /tmp/lazygit.tar.gz
            ;;
        fedora)
            sudo dnf copr enable atim/lazygit -y
            pkg_install lazygit
            ;;
        arch)
            pkg_install lazygit
            ;;
    esac

    log_success "lazygit installed"
}

install_delta() {
    if has delta; then
        log_success "delta (git-delta) already installed"
        return
    fi

    log_info "Installing delta (better git diffs)..."

    case "$OS" in
        debian)
            DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
            curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
            sudo dpkg -i /tmp/delta.deb || sudo apt-get install -f -y
            rm /tmp/delta.deb
            ;;
        fedora)
            pkg_install git-delta
            ;;
        arch)
            pkg_install git-delta
            ;;
    esac

    log_success "delta installed"
}

install_all_devtools() {
    install_devtools
    install_gh
    install_lazygit
    install_delta
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_devtools || true
