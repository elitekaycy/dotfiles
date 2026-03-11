#!/usr/bin/env bash
# Language runtimes via asdf: Node.js, Java, Python

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Ensure asdf is loaded
load_asdf() {
    if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
        . "$HOME/.asdf/asdf.sh"
    else
        log_error "asdf not installed. Run ./install.sh zsh first."
        return 1
    fi
}

install_nodejs() {
    load_asdf || return

    if asdf plugin list 2>/dev/null | grep -q nodejs; then
        log_success "asdf nodejs plugin already installed"
    else
        log_info "Adding asdf nodejs plugin..."
        asdf plugin add nodejs
    fi

    # Install latest LTS
    local version=$(asdf latest nodejs 22)
    if asdf list nodejs 2>/dev/null | grep -q "$version"; then
        log_success "Node.js $version already installed"
    else
        log_info "Installing Node.js $version..."
        asdf install nodejs "$version"
        asdf global nodejs "$version"
    fi

    log_success "Node.js ready ($(node --version 2>/dev/null || echo 'restart shell'))"
}

install_java() {
    load_asdf || return

    if asdf plugin list 2>/dev/null | grep -q java; then
        log_success "asdf java plugin already installed"
    else
        log_info "Adding asdf java plugin..."
        asdf plugin add java
    fi

    # Install Java 21 (LTS)
    local version="openjdk-21"
    if asdf list java 2>/dev/null | grep -q "$version"; then
        log_success "Java $version already installed"
    else
        log_info "Installing Java $version..."
        asdf install java "$version"
        asdf global java "$version"
    fi

    log_success "Java ready"
}

install_python() {
    load_asdf || return

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

    if asdf plugin list 2>/dev/null | grep -q python; then
        log_success "asdf python plugin already installed"
    else
        log_info "Adding asdf python plugin..."
        asdf plugin add python
    fi

    # Install Python 3.12
    local version=$(asdf latest python 3.12)
    if asdf list python 2>/dev/null | grep -q "$version"; then
        log_success "Python $version already installed"
    else
        log_info "Installing Python $version (this may take a while)..."
        asdf install python "$version"
        asdf global python "$version"
    fi

    log_success "Python ready"
}

install_pnpm() {
    load_asdf || return

    if has pnpm; then
        log_success "pnpm already installed"
        return
    fi

    log_info "Installing pnpm..."
    if has npm; then
        npm install -g pnpm
    elif has corepack; then
        corepack enable
        corepack prepare pnpm@latest --activate
    else
        curl -fsSL https://get.pnpm.io/install.sh | sh -
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
