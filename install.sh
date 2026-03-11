#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

# Source utilities
source "$INSTALL_DIR/utils.sh"

# Source all modules
source "$INSTALL_DIR/core.sh"
source "$INSTALL_DIR/i3.sh"
source "$INSTALL_DIR/terminal.sh"
source "$INSTALL_DIR/neovim.sh"
source "$INSTALL_DIR/devtools.sh"
source "$INSTALL_DIR/fonts.sh"
source "$INSTALL_DIR/greenclip.sh"
source "$INSTALL_DIR/rust.sh"
source "$INSTALL_DIR/zsh.sh"
source "$INSTALL_DIR/slack.sh"
source "$INSTALL_DIR/media.sh"
source "$INSTALL_DIR/docker.sh"
source "$INSTALL_DIR/chrome.sh"
source "$INSTALL_DIR/languages.sh"
source "$INSTALL_DIR/setup.sh"

# Ensure submodules are initialized (for pvim)
init_submodules() {
    if [[ -f "$SCRIPT_DIR/.gitmodules" ]]; then
        log_info "Initializing git submodules..."
        git -C "$SCRIPT_DIR" submodule update --init --recursive 2>/dev/null || true
    fi
}

show_help() {
    echo "Usage: ./install.sh [component]"
    echo ""
    echo "Components:"
    echo "  (none)     Install everything"
    echo "  core       Core packages (git, stow, curl, etc.)"
    echo "  i3         i3 window manager and tools"
    echo "  terminal   Kitty, tmux, zsh"
    echo "  devtools   All CLI tools via mise (bat, fd, fzf, eza, rg, etc.)"
    echo "  docker     Docker and Docker Compose"
    echo "  chrome     Google Chrome browser"
    echo "  languages  Node.js, Java, Python via mise"
    echo "  fonts      JetBrains Mono Nerd Font"
    echo "  greenclip  Clipboard manager"
    echo "  rust       Rust toolchain"
    echo "  zsh        Oh My Zsh, mise, atuin"
    echo "  stow       Symlink dotfiles only"
    echo "  setup      Run all setup (stow, themes, tmux, pvim)"
    echo "  pvim       Setup pvim (neovim config)"
    echo "  themes     Apply default theme"
    echo "  slack      Install Slack as web app"
    echo "  media      Spotify TUI, ani-cli, lobster (movies)"
    echo "  wallpapers Copy wallpapers"
    echo ""
}

main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       DOTFILES INSTALLATION           ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$OS" == "unknown" ]]; then
        log_error "Unsupported OS. Supports: Debian/Ubuntu, Fedora, Arch Linux."
        exit 1
    fi

    log_info "Detected OS: $OS"
    echo ""

    # Initialize
    init_submodules
    pkg_update
    echo ""

    # System packages (need apt/dnf/pacman)
    install_core
    install_i3
    install_greenclip
    install_terminal
    install_docker
    install_chrome
    install_rust
    install_fonts

    # Zsh ecosystem (installs mise)
    install_zsh_ecosystem

    # Stow dotfiles first so mise config.toml is in place
    echo ""
    log_info "Setting up configurations..."
    echo ""
    stow_dotfiles
    make_executable

    # Everything via mise (needs config.toml stowed first)
    install_devtools
    install_languages

    # Remaining setup
    setup_wallpapers
    setup_themes
    setup_tmux
    setup_pvim
    set_zsh_default

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       INSTALLATION COMPLETE!          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and log back in (or restart)"
    echo "  2. Select i3 as your window manager at login"
    echo "  3. Open a terminal and enjoy!"
    echo ""
}

# Handle arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    core)
        pkg_update && install_core
        ;;
    i3)
        pkg_update && install_i3
        ;;
    terminal)
        pkg_update && install_terminal
        ;;
    devtools)
        install_devtools
        ;;
    fonts)
        install_fonts
        ;;
    greenclip)
        install_greenclip
        ;;
    rust)
        install_rust
        ;;
    zsh)
        install_zsh_ecosystem
        ;;
    stow)
        stow_dotfiles && make_executable
        ;;
    setup)
        run_setup
        ;;
    pvim)
        setup_pvim
        ;;
    themes)
        setup_themes
        ;;
    slack)
        install_slack
        ;;
    media)
        install_media
        ;;
    docker)
        install_docker
        ;;
    chrome)
        install_chrome
        ;;
    languages)
        install_languages
        ;;
    wallpapers)
        setup_wallpapers
        ;;
    *)
        main
        ;;
esac
