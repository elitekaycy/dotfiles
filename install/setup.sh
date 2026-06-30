#!/usr/bin/env bash
# Setup: stow dotfiles, wallpapers, themes, tmux, pvim

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/deploy.sh"

stow_dotfiles() {
    deploy_dotfiles "${1:-false}"
}

setup_wallpapers() {
    log_info "Setting up wallpapers..."

    mkdir -p "$HOME/Pictures/wallpapers"

    if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
        cp -a "$DOTFILES_DIR/wallpapers/." "$HOME/Pictures/wallpapers/"
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
    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
    local current_theme_file="$state_dir/theme"
    local theme="tokyo-night"
    local reload="${1:-false}"
    log_info "Setting up theme switcher..."

    local apply_script="${XDG_CONFIG_HOME:-$HOME/.config}/themes/scripts/apply-theme.sh"

    if [[ -s "$current_theme_file" ]]; then
        theme="$(<"$current_theme_file")"
    fi

    if [[ -f "$apply_script" ]]; then
        log_info "Rendering theme ($theme)..."
        if [[ "$reload" == "true" ]]; then
            bash "$apply_script" "$theme"
        else
            bash "$apply_script" --no-reload "$theme"
        fi
        log_success "Theme rendered"
    else
        log_warn "Theme apply script not found, skipping"
    fi
}

setup_tmux() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    local old_tmux_target=""

    # Older revisions stowed the whole ~/.tmux directory into this repository.
    # Migrate only that known managed link so TPM can own its plugin directory.
    if [[ -L "$HOME/.tmux" ]]; then
        old_tmux_target="$(readlink "$HOME/.tmux")"
        if [[ "$old_tmux_target" == *"dotfiles/tmux/.tmux"* ]]; then
            rm -- "$HOME/.tmux"
        fi
    fi

    mkdir -p "$(dirname "$tpm_dir")"

    if [[ -d "$tpm_dir/.git" ]]; then
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
