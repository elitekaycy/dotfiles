#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/install/utils.sh"
source "$DOTFILES_DIR/install/setup.sh"
export PATH="$HOME/.local/bin:$PATH"

SYNC_GIT=true
SYNC_TOOLS=true
RELOAD_APPS=true
CHECK_ONLY=false
SYNC_WARNING=false

show_help() {
    cat <<'HELP'
Usage: ./update.sh [options]

Safely update the repository, reconcile Stow links, refresh generated theme
files and wallpapers, and install newly declared tools/plugins.

Options:
  --check         Fetch and verify only; do not deploy anything
  --local         Skip Git sync and deploy the current working tree
  --configs-only  Update links, themes, and wallpapers only
  --no-reload     Do not reload desktop applications
  -h, --help      Show this help

A dirty repository is never rebased, reset, or stashed automatically. The
current local configs are still deployed and the command exits with status 2.
HELP
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) CHECK_ONLY=true ;;
        --local) SYNC_GIT=false ;;
        --configs-only)
            SYNC_TOOLS=false
            RELOAD_APPS=false
            ;;
        --no-reload) RELOAD_APPS=false ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 2
            ;;
    esac
    shift
done

acquire_lock() {
    has flock || return 0

    local lock_dir="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles}"
    mkdir -p "$lock_dir"
    exec 9>"$lock_dir/update.lock"
    if ! flock -n 9; then
        log_error "Another dotfiles update is already running."
        exit 1
    fi
}

repository_is_clean() {
    [[ -z "$(git -C "$DOTFILES_DIR" status --porcelain --untracked-files=normal --ignore-submodules=none)" ]]
}

sync_repository() {
    local upstream

    if [[ "$SYNC_GIT" != "true" ]]; then
        log_info "Skipping Git sync (--local)."
        return 0
    fi

    if ! repository_is_clean; then
        log_warn "Repository has local changes; remote sync was skipped."
        log_warn "Commit/stash them first, or use --local when this is intentional."
        SYNC_WARNING=true
        return 0
    fi

    log_info "Fetching origin..."
    if ! git -C "$DOTFILES_DIR" fetch --prune origin; then
        log_warn "Origin could not be reached; applying the current checkout only."
        SYNC_WARNING=true
        return 0
    fi

    upstream="$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
    if [[ -z "$upstream" ]]; then
        log_warn "Current branch has no upstream; applying the current checkout only."
        SYNC_WARNING=true
        return 0
    fi

    log_info "Fast-forwarding from $upstream..."
    if ! git -C "$DOTFILES_DIR" merge --ff-only "$upstream"; then
        log_warn "The branch has diverged; no history was rewritten."
        SYNC_WARNING=true
        return 0
    fi

    if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
        git -C "$DOTFILES_DIR" submodule sync --recursive
        git -C "$DOTFILES_DIR" submodule update --init --recursive
    fi
}

sync_tools() {
    if [[ "$SYNC_TOOLS" != "true" ]]; then
        log_info "Skipping tool and plugin sync (--configs-only)."
        return 0
    fi

    if has mise; then
        log_info "Installing tools declared in mise config..."
        mise install
    else
        log_warn "mise is not installed; tool sync was skipped."
    fi

    setup_tmux
    local updater="$HOME/.tmux/plugins/tpm/bin/update_plugins"
    if [[ -x "$updater" ]]; then
        log_info "Updating tmux plugins..."
        "$updater" all || log_warn "Some tmux plugins could not be updated."
    fi
}

reload_desktop() {
    [[ "$RELOAD_APPS" == "true" ]] || return 0

    if has i3-msg; then
        i3-msg reload >/dev/null || true
    fi
    if has tmux && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "$HOME/.tmux.conf" || true
    fi
}

main() {
    acquire_lock
    sync_repository

    log_info "Verifying repository..."
    "$DOTFILES_DIR/scripts/verify.sh"

    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_success "Check complete; no configs were deployed."
        [[ "$SYNC_WARNING" == "false" ]] || return 2
        return 0
    fi

    stow_dotfiles
    make_executable
    setup_wallpapers
    setup_themes "$RELOAD_APPS"
    sync_tools
    reload_desktop

    log_success "Update complete. New shells will pick up shell changes."
    if [[ "$SYNC_WARNING" == "true" ]]; then
        log_warn "Configs were applied, but the repository was not synced with its upstream."
        return 2
    fi
}

main
