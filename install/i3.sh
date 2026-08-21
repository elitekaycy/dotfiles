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
                papirus-icon-theme
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
                papirus-icon-theme
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
                papirus-icon-theme
            ;;
    esac

    log_success "i3 packages installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_i3 || true
