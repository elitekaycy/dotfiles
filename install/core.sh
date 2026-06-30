#!/usr/bin/env bash
# Core packages: git, stow, curl, etc.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_core() {
    log_info "Installing core packages..."

    case "$OS" in
        debian)
            pkg_install git curl wget stow build-essential unzip xclip pciutils fontconfig
            ;;
        fedora)
            pkg_install git curl wget stow gcc make unzip xclip pciutils fontconfig
            ;;
        arch)
            pkg_install git curl wget stow base-devel unzip xclip pciutils fontconfig
            ;;
    esac

    log_success "Core packages installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_core || true
