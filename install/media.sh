#!/usr/bin/env bash
# Media tools: Spotify TUI, anime/movie streaming

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_mpv() {
    if has mpv; then
        log_success "mpv already installed"
        return
    fi

    log_info "Installing mpv..."
    case "$OS" in
        debian) pkg_install mpv ;;
        fedora) pkg_install mpv ;;
        arch) pkg_install mpv ;;
    esac
    log_success "mpv installed"
}

install_ncspot() {
    if has ncspot; then
        log_success "ncspot (Spotify TUI) already installed"
        return
    fi

    log_info "Installing ncspot (Spotify TUI)..."

    # Requires Rust
    if ! has cargo; then
        log_info "Installing Rust first..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Install dependencies
    case "$OS" in
        debian)
            pkg_install libncursesw5-dev libdbus-1-dev libpulse-dev libssl-dev libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev
            ;;
        fedora)
            pkg_install ncurses-devel dbus-devel pulseaudio-libs-devel openssl-devel libxcb-devel
            ;;
        arch)
            pkg_install ncurses dbus libpulse openssl libxcb
            ;;
    esac

    cargo install ncspot
    log_success "ncspot installed - Run 'ncspot' and login with Spotify"
}

install_ani_cli() {
    if has ani-cli; then
        log_success "ani-cli already installed"
        return
    fi

    log_info "Installing ani-cli..."

    # Dependencies
    case "$OS" in
        debian) pkg_install grep sed curl mpv aria2 ffmpeg fzf ;;
        fedora) pkg_install grep sed curl mpv aria2 ffmpeg fzf ;;
        arch) pkg_install grep sed curl mpv aria2 ffmpeg fzf ;;
    esac

    # Install ani-cli
    git clone --depth 1 https://github.com/pystardust/ani-cli.git /tmp/ani-cli
    sudo cp /tmp/ani-cli/ani-cli /usr/local/bin/
    sudo chmod +x /usr/local/bin/ani-cli
    rm -rf /tmp/ani-cli

    log_success "ani-cli installed - Run 'ani-cli' to search and watch anime"
}

install_lobster() {
    if has lobster; then
        log_success "lobster (movies/TV) already installed"
        return
    fi

    log_info "Installing lobster (movies/TV CLI)..."

    # Dependencies
    case "$OS" in
        debian) pkg_install curl mpv fzf ;;
        fedora) pkg_install curl mpv fzf ;;
        arch) pkg_install curl mpv fzf ;;
    esac

    # Install lobster
    curl -sL github.com/justchokingaround/lobster/raw/main/lobster.sh -o /tmp/lobster
    sudo mv /tmp/lobster /usr/local/bin/lobster
    sudo chmod +x /usr/local/bin/lobster

    log_success "lobster installed - Run 'lobster' to search movies/TV"
}

install_media() {
    install_mpv
    install_ncspot
    install_ani_cli
    install_lobster
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_media || true
