#!/usr/bin/env bash
# Login screen: SDDM with the astronaut theme, rendered from the active
# dotfiles theme by dots-login-sync. Replaces the current display manager.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

SDDM_THEME_REPO="https://github.com/Keyitdev/sddm-astronaut-theme.git"
# Upstream HEAD needs a Qt >= 6.5 greeter. Debian/Ubuntu ship a Qt5 greeter
# (last Qt5 release of the theme); Fedora/Arch ship a Qt6 greeter (last
# release before QtQuick.Effects). Both read the same theme.conf keys.
SDDM_THEME_REV_QT5="0e721d2"
SDDM_THEME_REV_QT6="48ea0a7"
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
                libqt5svg5 \
                qml-module-qtquick2 \
                qml-module-qtquick-controls2 \
                qml-module-qtquick-layouts \
                qml-module-qtgraphicaleffects \
                qml-module-qtquick-virtualkeyboard
            ;;
        fedora)
            pkg_install sddm git qt6-qtsvg qt6-qt5compat qt6-qtvirtualkeyboard qt6-qtmultimedia
            ;;
        arch)
            pkg_install sddm git qt6-svg qt6-5compat qt6-virtualkeyboard qt6-multimedia-ffmpeg
            ;;
    esac

    if [[ ! -d "$SDDM_THEME_DIR/.git" ]]; then
        log_info "Cloning sddm-astronaut-theme..."
        sudo git clone "$SDDM_THEME_REPO" "$SDDM_THEME_DIR"
    fi
    local rev="$SDDM_THEME_REV_QT6"
    [[ "$OS" == "debian" ]] && rev="$SDDM_THEME_REV_QT5"
    sudo git -C "$SDDM_THEME_DIR" checkout -q -f "$rev"

    # The Qt5 release references Assets/*.svgz but ships plain .svg files.
    local svg
    for svg in "$SDDM_THEME_DIR"/Assets/*.svg; do
        [[ -e "${svg}z" ]] || gzip -c "$svg" | sudo tee "${svg}z" >/dev/null
    done

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
    sudo install -d -m 755 -o "$user" -g "$group" "$SDDM_THEME_DIR/Themes"
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
