#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/install/utils.sh"
export PATH="$HOME/.local/bin:$PATH"

# Pull latest
log_info "Pulling latest dotfiles..."
git -C "$DOTFILES_DIR" pull --rebase --recurse-submodules
git -C "$DOTFILES_DIR" submodule update --init --recursive

# Auto-detect and stow all config dirs (skips non-config dirs)
SKIP_DIRS="install docs wallpapers"
log_info "Re-stowing configs..."
cd "$DOTFILES_DIR"
for dir in */; do
    dir="${dir%/}"
    [[ " $SKIP_DIRS " == *" $dir "* ]] && continue
    [[ -d "$dir" ]] && stow -R "$dir" 2>/dev/null || true
done

# Sync mise tools
log_info "Syncing mise tools..."
mise install
mise prune -y

# Sync tmux plugins
if [[ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    log_info "Syncing tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true
fi

log_success "Updated. Restart apps to pick up changes."
