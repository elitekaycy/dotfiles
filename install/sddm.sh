#!/usr/bin/env bash
# Login screen: SDDM with the astronaut theme, rendered from the active
# dotfiles theme by dots-login-sync. Replaces the current display manager.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

SDDM_THEME_REPO="https://github.com/Keyitdev/sddm-astronaut-theme.git"
SDDM_THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"

install_sddm() {
    log_info "Installing SDDM and the astronaut theme..."

    case "$OS" in
        debian)
            # Answer the "default display manager" debconf prompt up front.
            printf '%s shared/default-x-display-manager select sddm\n' sddm gdm3 lightdm \
                | sudo debconf-set-selections
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                sddm \
                git \
                libqt6svg6 \
                libxcb-cursor0 \
                qml6-module-qtquick-controls \
                qml6-module-qtquick-layouts \
                qml6-module-qtquick-effects \
                qml6-module-qt5compat-graphicaleffects \
                qml6-module-qtquick-virtualkeyboard \
                qml6-module-qtmultimedia
            ;;
        fedora)
            pkg_install sddm git qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia
            ;;
        arch)
            pkg_install sddm git qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
            ;;
    esac

    if [[ ! -d "$SDDM_THEME_DIR" ]]; then
        log_info "Cloning sddm-astronaut-theme..."
        sudo git clone --depth 1 "$SDDM_THEME_REPO" "$SDDM_THEME_DIR"
    fi

    # The greeter runs as the sddm user: it needs the UI font system-wide.
    local font_src="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    if [[ -d "$font_src" && ! -d /usr/local/share/fonts/JetBrainsMonoNerd ]]; then
        sudo mkdir -p /usr/local/share/fonts
        sudo cp -r "$font_src" /usr/local/share/fonts/JetBrainsMonoNerd
        sudo fc-cache -f >/dev/null
    fi

    # Two user-owned slots inside the theme so dots-login-sync can re-render
    # the login screen on every theme or wallpaper change without sudo.
    local user group
    user="$(id -un)"
    group="$(id -gn)"
    sudo install -d -m 755 -o "$user" -g "$group" "$SDDM_THEME_DIR/Backgrounds/dotfiles"
    [[ -e "$SDDM_THEME_DIR/Themes/dotfiles.conf" ]] || sudo touch "$SDDM_THEME_DIR/Themes/dotfiles.conf"
    sudo chown "$user:$group" "$SDDM_THEME_DIR/Themes/dotfiles.conf"
    sudo chmod 644 "$SDDM_THEME_DIR/Themes/dotfiles.conf"
    sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/dotfiles.conf|' "$SDDM_THEME_DIR/metadata.desktop"

    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/dotfiles.conf >/dev/null <<'CONF'
# Managed by dotfiles (install/sddm.sh)
[Theme]
Current=sddm-astronaut-theme
CONF

    if [[ -x "$HOME/.local/bin/dots-login-sync" ]]; then
        "$HOME/.local/bin/dots-login-sync"
    else
        log_warn "dots-login-sync not deployed yet; run ./install.sh stow && dots-login-sync"
    fi

    # Make sddm the active display manager.
    local dm
    for dm in gdm gdm3 lightdm lxdm; do
        if systemctl list-unit-files "$dm.service" --no-legend 2>/dev/null | grep -q "^$dm.service"; then
            sudo systemctl disable "$dm.service" >/dev/null 2>&1 || true
        fi
    done
    sudo systemctl enable --force sddm.service >/dev/null
    if [[ "$OS" == "debian" ]]; then
        printf '/usr/bin/sddm\n' | sudo tee /etc/X11/default-display-manager >/dev/null
    fi

    log_success "SDDM installed; the login screen switches on the next reboot"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_sddm || true
