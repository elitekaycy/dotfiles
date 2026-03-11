#!/usr/bin/env bash
# Google Chrome installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_chrome() {
    if has google-chrome || has google-chrome-stable; then
        log_success "Google Chrome already installed"
        return
    fi

    log_info "Installing Google Chrome..."

    case "$OS" in
        debian)
            wget -q -O /tmp/google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
            sudo dpkg -i /tmp/google-chrome.deb || sudo apt-get install -f -y
            rm /tmp/google-chrome.deb
            ;;
        fedora)
            sudo dnf install -y fedora-workstation-repositories
            sudo dnf config-manager --set-enabled google-chrome
            pkg_install google-chrome-stable
            ;;
        arch)
            # Chrome is in AUR, use yay if available
            if has yay; then
                yay -S --noconfirm google-chrome
            else
                log_warn "Chrome requires AUR helper (yay). Installing yay first..."
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay && makepkg -si --noconfirm
                yay -S --noconfirm google-chrome
            fi
            ;;
    esac

    log_success "Google Chrome installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_chrome || true
