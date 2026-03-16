#!/usr/bin/env bash
# Setup: stow dotfiles, wallpapers, themes, tmux, pvim

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

stow_dotfiles() {
    log_info "Stowing dotfiles..."

    cd "$DOTFILES_DIR"

    local configs=(bash zsh i3 kitty tmux nvim pvim rofi dunst picom polybar themes git mise)

    for config in "${configs[@]}"; do
        if [[ -d "$config" ]]; then
            log_info "  Stowing $config..."
            stow -D "$config" >/dev/null 2>&1
            stow "$config" >/dev/null 2>&1
        fi
    done

    log_success "Dotfiles stowed"
}

setup_wallpapers() {
    log_info "Setting up wallpapers..."

    mkdir -p "$HOME/Pictures/wallpapers"

    if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
        cp -r "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
        log_success "Wallpapers copied to ~/Pictures/wallpapers/"
    else
        log_warn "No wallpapers directory found in dotfiles"
    fi
}

make_executable() {
    log_info "Making scripts executable..."

    chmod +x "$DOTFILES_DIR"/i3/.config/i3/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/i3/*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR"/polybar/.config/polybar/*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR"/polybar/.config/polybar/scripts/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/polybar/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/polybar/scripts/*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR"/themes/.config/themes/scripts/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/themes/scripts/*.sh 2>/dev/null || true

    log_success "Scripts are executable"
}

setup_themes() {
    log_info "Setting up theme switcher..."

    local apply_script="$HOME/.config/themes/scripts/apply-theme.sh"

    if [[ -f "$apply_script" ]]; then
        log_info "Applying default theme (tokyo-night)..."
        bash "$apply_script" tokyo-night || true
        log_success "Default theme applied"
    else
        log_warn "Theme apply script not found, skipping"
    fi
}

setup_tmux() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log_success "TPM already installed"
    else
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
    fi

    if [[ -f "$tpm_dir/bin/install_plugins" ]]; then
        log_info "Installing tmux plugins..."
        "$tpm_dir/bin/install_plugins" || true
    fi
}

setup_pvim() {
    local pvim_install="$DOTFILES_DIR/pvim/.config/pvim/install.sh"

    if [[ -f "$pvim_install" ]]; then
        log_info "Running pvim installer..."
        bash "$pvim_install"
    else
        log_warn "pvim install.sh not found, skipping"
    fi
}

run_setup() {
    stow_dotfiles
    setup_wallpapers
    make_executable
    setup_themes
    setup_tmux
    setup_pvim
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && run_setup || true
