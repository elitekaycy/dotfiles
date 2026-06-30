#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() { printf 'test-deploy: %s\n' "$1" >&2; exit 1; }

run_deploy() {
    local home="$1"
    HOME="$home" \
    DOTFILES_TARGET_HOME="$home" \
    XDG_STATE_HOME="$home/.local/state" \
        bash -c 'source "$1/install/setup.sh"; stow_dotfiles' _ "$ROOT"
}

fresh_home="$TEST_ROOT/fresh"
mkdir -p "$fresh_home"
run_deploy "$fresh_home"
[[ -L "$fresh_home/.bashrc" ]] || fail "fresh .bashrc was not linked"
[[ -d "$fresh_home/.config/nvim" && ! -L "$fresh_home/.config/nvim" ]] || fail "--no-folding was not honored"
[[ -L "$fresh_home/.config/nvim/lazyvim.json" ]] || fail "nested Neovim config was not linked"
[[ ! -e "$fresh_home/.config/pvim/undo" ]] || fail "pvim runtime undo state was deployed"
run_deploy "$fresh_home"
[[ ! -d "$fresh_home/.local/state/dotfiles/backups" ]] || fail "idempotent deploy created a backup"

existing_home="$TEST_ROOT/existing"
mkdir -p "$existing_home/.config/nvim"
printf 'local bashrc\n' > "$existing_home/.bashrc"
printf 'keep me\n' > "$existing_home/.config/nvim/local-only.lua"
printf 'global ignores\n' > "$existing_home/.gitignore"
ln -s "$ROOT/tmux/.tmux" "$existing_home/.tmux"
run_deploy "$existing_home"
[[ -L "$existing_home/.bashrc" ]] || fail "existing .bashrc was not replaced by a link"
[[ "$(<"$existing_home/.config/nvim/local-only.lua")" == "keep me" ]] || fail "unmanaged config was changed"
[[ -d "$existing_home/.tmux" && ! -L "$existing_home/.tmux" ]] || fail "legacy tmux plugin link was not migrated"
[[ "$(<"$existing_home/.gitignore")" == "global ignores" ]] || fail "Stow-ignored .gitignore was changed"
backup_bashrc="$(find "$existing_home/.local/state/dotfiles/backups" -path '*/.bashrc' -type f -print -quit)"
[[ -n "$backup_bashrc" && "$(<"$backup_bashrc")" == "local bashrc" ]] || fail "conflict backup is missing"
backup_count="$(find "$existing_home/.local/state/dotfiles/backups" -mindepth 1 -maxdepth 1 -type d | wc -l)"
run_deploy "$existing_home"
[[ "$(find "$existing_home/.local/state/dotfiles/backups" -mindepth 1 -maxdepth 1 -type d | wc -l)" == "$backup_count" ]] || fail "second deploy created a redundant backup"

printf 'test-deploy: passed\n'
