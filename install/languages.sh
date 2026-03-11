#!/usr/bin/env bash
# Language runtimes - all managed by mise
# See mise/.config/mise/config.toml for versions

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_languages() {
    if ! has mise; then
        log_error "mise not installed. Run ./install.sh zsh first."
        return 1
    fi

    # Python build dependencies (needed for mise to compile Python)
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

    log_info "Installing languages via mise..."
    mise install node java python maven gradle pnpm
    log_success "Languages installed via mise"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_languages || true
