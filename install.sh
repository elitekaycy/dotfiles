#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop|linuxmint) echo "debian" ;;
            fedora) echo "fedora" ;;
            arch|manjaro|endeavouros) echo "arch" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

# Package manager helpers
pkg_install() {
    case "$OS" in
        debian) sudo apt-get install -y "$@" ;;
        fedora) sudo dnf install -y "$@" ;;
        arch) sudo pacman -S --noconfirm "$@" ;;
    esac
}

pkg_update() {
    case "$OS" in
        debian) sudo apt-get update ;;
        fedora) sudo dnf check-update || true ;;
        arch) sudo pacman -Sy ;;
    esac
}

# Check if command exists
has() { command -v "$1" &>/dev/null; }

# ============================================================
# CORE PACKAGES
# ============================================================
install_core() {
    log_info "Installing core packages..."

    case "$OS" in
        debian)
            pkg_install git curl wget stow build-essential
            ;;
        fedora)
            pkg_install git curl wget stow gcc make
            ;;
        arch)
            pkg_install git curl wget stow base-devel
            ;;
    esac

    log_success "Core packages installed"
}

# ============================================================
# I3 WINDOW MANAGER
# ============================================================
install_i3() {
    log_info "Installing i3 and related packages..."

    case "$OS" in
        debian)
            pkg_install \
                i3 \
                i3blocks \
                i3lock \
                rofi \
                dmenu \
                feh \
                brightnessctl \
                network-manager-gnome \
                volumeicon-alsa \
                blueman \
                xinput \
                acpi \
                alsa-utils \
                pulseaudio-utils \
                lm-sensors \
                redshift \
                flameshot \
                picom
            ;;
        fedora)
            pkg_install \
                i3 \
                i3blocks \
                i3lock \
                rofi \
                dmenu \
                feh \
                brightnessctl \
                network-manager-applet \
                volumeicon \
                blueman \
                xinput \
                acpi \
                alsa-utils \
                pulseaudio-utils \
                lm_sensors \
                redshift \
                flameshot \
                picom
            ;;
        arch)
            pkg_install \
                i3-wm \
                i3blocks \
                i3lock \
                rofi \
                dmenu \
                feh \
                brightnessctl \
                network-manager-applet \
                volumeicon \
                blueman \
                xorg-xinput \
                acpi \
                alsa-utils \
                pulseaudio \
                lm_sensors \
                redshift \
                flameshot \
                picom
            ;;
    esac

    log_success "i3 packages installed"
}

# ============================================================
# TERMINAL (Kitty + Tmux + Zsh)
# ============================================================
install_terminal() {
    log_info "Installing terminal packages..."

    case "$OS" in
        debian) pkg_install kitty tmux zsh ;;
        fedora) pkg_install kitty tmux zsh ;;
        arch) pkg_install kitty tmux zsh ;;
    esac

    log_success "Terminal packages installed"
}

# ============================================================
# DEV TOOLS (bat, fd, fzf, eza, ripgrep, btop)
# ============================================================
install_devtools() {
    log_info "Installing development tools..."

    case "$OS" in
        debian)
            pkg_install bat fd-find fzf ripgrep btop
            # eza needs special install on debian
            if ! has eza; then
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt-get update
                pkg_install eza
            fi
            ;;
        fedora)
            pkg_install bat fd-find fzf ripgrep eza btop
            ;;
        arch)
            pkg_install bat fd fzf ripgrep eza btop
            ;;
    esac

    log_success "Development tools installed"
}

# ============================================================
# RUST / CARGO
# ============================================================
install_rust() {
    if has rustc; then
        log_success "Rust already installed"
        return
    fi

    log_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    log_success "Rust installed"
}

# ============================================================
# OH MY ZSH
# ============================================================
install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh already installed"
        return
    fi

    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed"
}

# ============================================================
# ASDF VERSION MANAGER
# ============================================================
install_asdf() {
    if [[ -d "$HOME/.asdf" ]]; then
        log_success "asdf already installed"
        return
    fi

    log_info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    log_success "asdf installed"
}

# ============================================================
# ATUIN (Shell History)
# ============================================================
install_atuin() {
    if has atuin; then
        log_success "Atuin already installed"
        return
    fi

    log_info "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    log_success "Atuin installed"
}

# ============================================================
# NERD FONTS
# ============================================================
install_fonts() {
    local font_dir="$HOME/.local/share/fonts"

    if fc-list | grep -qi "JetBrains"; then
        log_success "JetBrains Mono Nerd Font already installed"
        return
    fi

    log_info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$font_dir"

    local version="v3.1.1"
    curl -Lo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d "$font_dir"
    rm /tmp/JetBrainsMono.zip

    fc-cache -fv
    log_success "Fonts installed"
}

# ============================================================
# SLACK (Web App - replaces desktop app)
# ============================================================
install_slack() {
    log_info "Installing Slack as a web app..."

    # Remove snap version if exists
    if snap list slack &>/dev/null; then
        log_info "Removing Slack snap..."
        sudo snap remove slack
    fi

    # Remove deb version if exists
    if dpkg -l | grep -q slack-desktop; then
        log_info "Removing Slack desktop..."
        sudo apt remove -y slack-desktop
    fi

    # Create webapp directories
    mkdir -p ~/.local/share/webapps/slack-chrome-profile
    mkdir -p ~/.local/share/applications

    # Create desktop entry
    cat > ~/.local/share/applications/slack-webapp.desktop << 'SLACKEOF'
[Desktop Entry]
Version=1.0
Name=Slack
Comment=Slack Web App
Exec=google-chrome --app=https://app.slack.com --class=SlackWebApp --user-data-dir=~/.local/share/webapps/slack-chrome-profile --no-first-run --disable-infobars --disable-session-crashed-bubble
Icon=slack
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=SlackWebApp
SLACKEOF

    log_success "Slack web app installed"
    log_info "Launch with: rofi/dmenu -> 'Slack'"
}

# ============================================================
# STOW DOTFILES
# ============================================================
stow_dotfiles() {
    log_info "Stowing dotfiles..."

    cd "$DOTFILES_DIR"

    # List of directories to stow
    local configs=(bash zsh i3 i3status kitty tmux nvim pvim)

    for config in "${configs[@]}"; do
        if [[ -d "$config" ]]; then
            log_info "  Stowing $config..."
            stow -R "$config" 2>/dev/null || stow "$config"
        fi
    done

    log_success "Dotfiles stowed"
}

# ============================================================
# MAKE SCRIPTS EXECUTABLE
# ============================================================
make_executable() {
    log_info "Making scripts executable..."

    chmod +x "$DOTFILES_DIR"/i3/.config/i3/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/i3/*.sh 2>/dev/null || true

    log_success "Scripts are executable"
}

# ============================================================
# TMUX PLUGINS
# ============================================================
setup_tmux() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log_success "TPM already installed"
    else
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
    fi

    # Install plugins
    if [[ -f "$tpm_dir/bin/install_plugins" ]]; then
        log_info "Installing tmux plugins..."
        "$tpm_dir/bin/install_plugins" || true
    fi
}

# ============================================================
# PVIM (Neovim Config)
# ============================================================
setup_pvim() {
    local pvim_install="$DOTFILES_DIR/pvim/.config/pvim/install.sh"

    if [[ -f "$pvim_install" ]]; then
        log_info "Running pvim installer..."
        bash "$pvim_install"
    else
        log_warn "pvim install.sh not found, skipping"
    fi
}

# ============================================================
# CHANGE DEFAULT SHELL
# ============================================================
set_zsh_default() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "Zsh is already default shell"
        return
    fi

    log_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Zsh set as default (restart terminal to apply)"
}

# ============================================================
# MAIN
# ============================================================
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       DOTFILES INSTALLATION           ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$OS" == "unknown" ]]; then
        log_error "Unsupported OS. This script supports Debian/Ubuntu, Fedora, and Arch Linux."
        exit 1
    fi

    log_info "Detected OS: $OS"
    echo ""

    # Update package manager
    log_info "Updating package manager..."
    pkg_update
    echo ""

    # Install everything
    install_core
    install_i3
    install_terminal
    install_devtools
    install_rust
    install_ohmyzsh
    install_asdf
    install_atuin
    install_fonts

    echo ""
    log_info "Setting up configurations..."
    echo ""

    stow_dotfiles
    make_executable
    setup_tmux
    setup_pvim
    set_zsh_default

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       INSTALLATION COMPLETE!          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Log out and log back in (or restart)"
    echo -e "  2. Select i3 as your window manager at login"
    echo -e "  3. Open a terminal and enjoy!"
    echo ""
    echo -e "Optional: Install productivity apps:"
    echo -e "  - Slack: ${YELLOW}./install.sh slack${NC} (web app)"
    echo -e "  - Spotify: ${YELLOW}snap install spotify${NC}"
    echo -e "  - Obsidian: ${YELLOW}snap install obsidian${NC}"
    echo ""
}

# Run with optional component selection
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: ./install.sh [component]"
    echo ""
    echo "Components:"
    echo "  (none)     Install everything"
    echo "  core       Core packages only (git, stow, etc.)"
    echo "  i3         i3 window manager and tools"
    echo "  terminal   Kitty, tmux, zsh"
    echo "  devtools   bat, fd, fzf, eza, ripgrep, btop"
    echo "  fonts      JetBrains Mono Nerd Font"
    echo "  stow       Symlink dotfiles only"
    echo "  pvim       Setup pvim (neovim config)"
    echo "  slack      Install Slack as web app (removes desktop app)"
    echo ""
    exit 0
fi

case "$1" in
    core) pkg_update && install_core ;;
    i3) pkg_update && install_i3 ;;
    terminal) pkg_update && install_terminal ;;
    devtools) pkg_update && install_devtools ;;
    fonts) install_fonts ;;
    stow) stow_dotfiles && make_executable ;;
    pvim) setup_pvim ;;
    slack) install_slack ;;
    *) main ;;
esac
