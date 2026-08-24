#!/usr/bin/env bash
# Pritunl VPN client (OpenVPN/WireGuard GUI + CLI)

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

PRITUNL_GPG_URL="https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc"
PRITUNL_KEY_FINGERPRINT="7568D9BB55FF9E5287D586017AE645C0CF8E292A"

install_pritunl() {
    if has pritunl-client; then
        log_success "Pritunl client already installed"
        return
    fi

    log_info "Installing Pritunl client..."

    case "$OS" in
        debian)
            curl -fsSL "$PRITUNL_GPG_URL" | sudo gpg -o /usr/share/keyrings/pritunl.gpg --dearmor --yes
            echo "deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt $(lsb_release -cs) main" \
                | sudo tee /etc/apt/sources.list.d/pritunl.list >/dev/null
            sudo apt-get update
            pkg_install pritunl-client-electron
            ;;
        fedora)
            sudo tee /etc/yum.repos.d/pritunl.repo >/dev/null <<REPO
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/fedora/$(rpm -E %fedora)/
gpgcheck=1
enabled=1
gpgkey=$PRITUNL_GPG_URL
REPO
            pkg_install pritunl-client-electron
            ;;
        arch)
            if ! grep -q '^\[pritunl\]' /etc/pacman.conf; then
                sudo tee -a /etc/pacman.conf >/dev/null <<REPO

[pritunl]
Server = https://repo.pritunl.com/stable/pacman
REPO
            fi
            curl -fsSL "$PRITUNL_GPG_URL" | sudo pacman-key --add -
            sudo pacman-key --lsign-key "$PRITUNL_KEY_FINGERPRINT"
            sudo pacman -Sy
            pkg_install pritunl-client-electron
            ;;
    esac

    log_success "Pritunl client installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_pritunl || true
