#!/usr/bin/env bash
# i3 window manager and related packages

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_i3() {
    log_info "Installing i3 and related packages..."

    case "$OS" in
        debian)
            pkg_install \
                i3 \
                i3lock \
                rofi \
                feh \
                brightnessctl \
                network-manager-gnome \
                blueman \
                firefox \
                volumeicon-alsa \
                x11-xserver-utils \
                xinput \
                acpi \
                alsa-utils \
                pulseaudio-utils \
                pavucontrol \
                lm-sensors \
                redshift \
                flameshot \
                picom \
                dunst \
                playerctl \
                xss-lock \
                polybar \
                papirus-icon-theme \
                libsecret-tools
            ;;
        fedora)
            pkg_install \
                i3 \
                i3lock \
                rofi \
                feh \
                brightnessctl \
                network-manager-applet \
                blueman \
                firefox \
                volumeicon \
                xorg-x11-server-utils \
                xinput \
                acpi \
                alsa-utils \
                pulseaudio-utils \
                pavucontrol \
                lm_sensors \
                redshift \
                flameshot \
                picom \
                dunst \
                playerctl \
                xss-lock \
                polybar \
                papirus-icon-theme \
                libsecret-tools
            ;;
        arch)
            pkg_install \
                i3-wm \
                i3lock \
                rofi \
                feh \
                brightnessctl \
                network-manager-applet \
                blueman \
                firefox \
                volumeicon \
                xorg-xset \
                xorg-xinput \
                acpi \
                alsa-utils \
                pulseaudio \
                pavucontrol \
                lm_sensors \
                redshift \
                flameshot \
                picom \
                dunst \
                playerctl \
                xss-lock \
                polybar \
                papirus-icon-theme \
                libsecret-tools
            ;;
    esac

    log_success "i3 packages installed"
    install_i3lock_color
}

# i3lock-color (blur, clock, ring indicator) is not packaged on Debian/Ubuntu;
# build it as /usr/local/bin/i3lock-color next to the distro i3lock, which
# keeps providing /etc/pam.d/i3lock and the plain fallback.
install_i3lock_color() {
    if has i3lock-color; then
        log_success "i3lock-color already installed"
        return
    fi

    log_info "Building i3lock-color..."
    case "$OS" in
        debian)
            pkg_install \
                build-essential git autoconf automake pkg-config \
                libpam0g-dev libcairo2-dev libfontconfig1-dev libev-dev \
                libx11-xcb-dev libxcb-composite0-dev libxcb-xkb-dev libxcb-xinerama0-dev \
                libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev \
                libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
            ;;
        fedora)
            pkg_install \
                gcc make git autoconf automake pkgconf-pkg-config \
                pam-devel cairo-devel fontconfig-devel libev-devel libX11-devel \
                libxcb-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel \
                libxkbcommon-devel libxkbcommon-x11-devel libjpeg-turbo-devel giflib-devel
            ;;
        arch)
            pkg_install \
                base-devel git cairo libev libjpeg-turbo libxkbcommon-x11 \
                xcb-util-image xcb-util-xrm giflib pam fontconfig
            ;;
    esac

    local src
    src="$(mktemp -d)"
    git clone --depth 1 https://github.com/Raymo111/i3lock-color.git "$src"
    (
        set -e
        cd "$src"
        autoreconf -fi
        mkdir -p build
        cd build
        ../configure --prefix=/usr/local --program-suffix=-color
        make -j"$(nproc)"
        sudo make install
    )
    rm -rf "$src"
    log_success "i3lock-color installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_i3 || true
