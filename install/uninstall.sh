#!/usr/bin/env bash
# Backup existing configs before stow to avoid conflicts
# Moves existing files/dirs to ~/.config-backup/

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

BACKUP_DIR="$HOME/.config-backup"

backup_if_exists() {
    local target="$1"
    # Skip if it's already a symlink (from a previous stow)
    [[ -L "$target" ]] && return
    # Skip if it doesn't exist
    [[ ! -e "$target" ]] && return

    local relative="${target#$HOME/}"
    local backup_path="$BACKUP_DIR/$relative"

    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    log_info "  Backed up $relative"
}

uninstall() {
    log_info "Backing up existing configs to $BACKUP_DIR ..."

    # Top-level dotfiles
    backup_if_exists "$HOME/.bashrc"
    backup_if_exists "$HOME/.zshrc"
    backup_if_exists "$HOME/.tmux.conf"
    backup_if_exists "$HOME/.tmux"
    backup_if_exists "$HOME/.gitconfig"
    backup_if_exists "$HOME/.gitignore"
    backup_if_exists "$HOME/.luarc.json"
    backup_if_exists "$HOME/.neoconf.json"

    # .config subdirs
    local config_dirs=(i3 kitty nvim pvim rofi dunst picom polybar themes mise)
    for dir in "${config_dirs[@]}"; do
        backup_if_exists "$HOME/.config/$dir"
    done

    # oh-my-zsh (can conflict with fresh install)
    backup_if_exists "$HOME/.oh-my-zsh"

    # fzf (reinstalled by mise now)
    backup_if_exists "$HOME/.fzf"
    backup_if_exists "$HOME/.fzf.zsh"
    backup_if_exists "$HOME/.fzf.bash"

    # old z directory (replaced by zoxide)
    backup_if_exists "$HOME/z"

    log_success "Backup complete. Restore from $BACKUP_DIR if needed."
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && uninstall || true
