#!/usr/bin/env bash
# Conflict-aware GNU Stow deployment shared by install.sh and update.sh.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOTFILES_TARGET_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
DOTFILES_STATE_HOME="${XDG_STATE_HOME:-$DOTFILES_TARGET_HOME/.local/state}/dotfiles"
DOTFILES_PACKAGES=(
    bash
    zsh
    i3
    kitty
    tmux
    nvim
    pvim
    bin
    picom
    polybar
    themes
    git
    mise
    broot
    vim
    idea
    gtk
)

_dotfiles_backup_dir=""

dotfiles_backup_dir() {
    if [[ -z "$_dotfiles_backup_dir" ]]; then
        _dotfiles_backup_dir="$DOTFILES_STATE_HOME/backups/$(date +%Y%m%d-%H%M%S)-$$"
    fi
}

backup_conflict() {
    local target="$1"
    local relative="${target#"$DOTFILES_TARGET_HOME"/}"
    local backup_path

    dotfiles_backup_dir
    backup_path="$_dotfiles_backup_dir/$relative"
    mkdir -p "$(dirname "$backup_path")"
    mv -- "$target" "$backup_path"
    log_warn "Backed up conflicting $relative"
}

paths_resolve_to_same_file() {
    local source="$1"
    local target="$2"
    local source_real
    local target_real

    source_real="$(readlink -f -- "$source" 2>/dev/null || true)"
    target_real="$(readlink -f -- "$target" 2>/dev/null || true)"
    [[ -n "$source_real" && "$source_real" == "$target_real" ]]
}

stow_ignores_relative_path() {
    local relative="$1"
    local basename="${relative##*/}"

    case "/$relative/" in
        */.git/*|*/.svn/*|*/CVS/*) return 0 ;;
    esac
    case "$basename" in
        .git|.gitignore|.gitmodules|.stow-local-ignore|*.swp|*~) return 0 ;;
    esac
    case "$relative" in
        README*|LICENSE*|COPYING*) return 0 ;;
    esac
    return 1
}
prepare_package_conflicts() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"
    local source
    local relative
    local target

    # Real directories are merged. Foreign symlinks and non-directories are
    # backed up before Stow sees them.
    while IFS= read -r -d '' source; do
        relative="${source#"$package_dir"/}"
        target="$DOTFILES_TARGET_HOME/$relative"

        stow_ignores_relative_path "$relative" && continue
        if [[ -L "$target" ]]; then
            paths_resolve_to_same_file "$source" "$target" || backup_conflict "$target"
        elif [[ -e "$target" && ! -d "$target" ]]; then
            backup_conflict "$target"
        fi
    done < <(find "$package_dir" -mindepth 1 -type d -print0)

    # Back up only leaf paths that would actually be overwritten. Existing
    # Stow links are left for `stow --restow` to reconcile.
    while IFS= read -r -d '' source; do
        relative="${source#"$package_dir"/}"
        target="$DOTFILES_TARGET_HOME/$relative"
        stow_ignores_relative_path "$relative" && continue

        if [[ -e "$target" || -L "$target" ]]; then
            paths_resolve_to_same_file "$source" "$target" || backup_conflict "$target"
        fi
    done < <(find "$package_dir" -mindepth 1 \( -type f -o -type l \) -print0)
}
migrate_legacy_layout() {
    local tmux_home="$DOTFILES_TARGET_HOME/.tmux"
    local link_target=""

    [[ -L "$tmux_home" ]] || return 0
    link_target="$(readlink "$tmux_home")"

    case "$link_target" in
        "$DOTFILES_DIR/tmux/.tmux"|*dotfiles/tmux/.tmux)
            rm -- "$tmux_home"
            mkdir -p "$tmux_home"
            log_info "Migrated the legacy repository-owned ~/.tmux directory"
            ;;
    esac
}

deploy_dotfiles() {
    local dry_run="${1:-false}"
    local package
    local stow_args=(
        --dir="$DOTFILES_DIR"
        --target="$DOTFILES_TARGET_HOME"
        --restow
        --ignore='(^|/)undo(/|$)'
        --no-folding
    )

    if ! has stow; then
        log_error "GNU Stow is required. Run ./install.sh core first."
        return 1
    fi

    mkdir -p "$DOTFILES_TARGET_HOME"

    if [[ "$dry_run" == "true" ]]; then
        stow_args+=(--simulate --verbose=1)
        log_info "Checking dotfile deployment (no files will change)..."
    else
        log_info "Deploying dotfiles to $DOTFILES_TARGET_HOME ..."
        migrate_legacy_layout
    fi

    for package in "${DOTFILES_PACKAGES[@]}"; do
        [[ -d "$DOTFILES_DIR/$package" ]] || continue
        log_info "  $package"
        if [[ "$dry_run" != "true" ]]; then
            prepare_package_conflicts "$package"
        fi
        stow "${stow_args[@]}" "$package"
    done

    if [[ -n "$_dotfiles_backup_dir" ]]; then
        log_success "Conflicts preserved in $_dotfiles_backup_dir"
    fi
    log_success "Dotfiles deployed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deploy_dotfiles "${1:-false}"
fi
