#!/usr/bin/env bash
# Language runtimes via mise: Node.js, Java, Python

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Ensure mise is available
check_mise() {
    if ! has mise; then
        log_error "mise not installed. Run ./install.sh zsh first."
        return 1
    fi
    # Activate mise for current shell
    eval "$(mise activate bash 2>/dev/null)" || true
}

install_nodejs() {
    check_mise || return

    log_info "Installing Node.js via mise..."

    # Install Node.js 22 (LTS)
    if mise list node 2>/dev/null | grep -q "22"; then
        log_success "Node.js 22 already installed"
    else
        mise use --global node@22
    fi

    log_success "Node.js ready ($(mise exec -- node --version 2>/dev/null || echo 'restart shell'))"
}

install_java() {
    check_mise || return

    log_info "Installing Java via mise..."

    # Install Java 21 (LTS)
    if mise list java 2>/dev/null | grep -q "21"; then
        log_success "Java 21 already installed"
    else
        mise use --global java@21
    fi

    log_success "Java ready"
}

install_python() {
    check_mise || return

    # Python build dependencies
    case "$OS" in
        debian)
            pkg_install build-essential libssl-dev zlib1g-dev libbz2-dev \
                libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils \
                tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
            ;;
        fedora)
            pkg_install gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite \
                sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
            ;;
        arch)
            pkg_install base-devel openssl zlib xz tk
            ;;
    esac

    log_info "Installing Python via mise..."

    # Install Python 3.12
    if mise list python 2>/dev/null | grep -q "3.12"; then
        log_success "Python 3.12 already installed"
    else
        mise use --global python@3.12
    fi

    log_success "Python ready"
}

install_pnpm() {
    check_mise || return

    if has pnpm; then
        log_success "pnpm already installed"
        return
    fi

    log_info "Installing pnpm..."

    # Use mise to install pnpm directly (it supports it)
    if mise plugins ls 2>/dev/null | grep -q pnpm; then
        mise use --global pnpm@latest
    else
        # Fallback to npm install
        mise exec -- npm install -g pnpm 2>/dev/null || curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi

    log_success "pnpm installed"
}

install_languages() {
    install_nodejs
    install_pnpm
    install_java
    install_python
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_languages || true
