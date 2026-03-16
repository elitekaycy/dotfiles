#!/usr/bin/env bash
# NVIDIA driver detection and installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_nvidia() {
    # Check if NVIDIA GPU is present
    if ! lspci | grep -qi nvidia; then
        log_info "No NVIDIA GPU detected, skipping driver install"
        return
    fi

    # Check if driver is already loaded
    if lsmod | grep -q nvidia; then
        log_success "NVIDIA driver already loaded ($(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo 'version unknown'))"
        return
    fi

    log_info "NVIDIA GPU detected, installing drivers..."

    case "$OS" in
        debian)
            # Install recommended driver automatically
            pkg_install ubuntu-drivers-common
            sudo ubuntu-drivers install 2>/dev/null || {
                # Fallback: install open kernel module variant
                log_info "Auto-detect failed, installing nvidia-driver-open..."
                pkg_install nvidia-driver-open
            }
            ;;
        fedora)
            # Enable RPM Fusion for NVIDIA
            sudo dnf install -y \
                "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
                2>/dev/null || true
            pkg_install akmod-nvidia xorg-x11-drv-nvidia
            ;;
        arch)
            pkg_install nvidia nvidia-utils nvidia-settings
            ;;
    esac

    log_success "NVIDIA drivers installed (reboot required)"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_nvidia || true
