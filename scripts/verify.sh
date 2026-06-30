#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log() { printf '[verify] %s\n' "$1"; }
fail() { printf '[verify] ERROR: %s\n' "$1" >&2; exit 1; }

log "checking whitespace"
git diff --check

log "checking shell syntax"
while IFS= read -r script; do
    bash -n "$script"
done < <(git ls-files --cached --others --exclude-standard '*.sh' | sort -u)
zsh -n zsh/.zshrc

if command -v shellcheck >/dev/null; then
    log "running ShellCheck"
    mapfile -t shell_scripts < <(git ls-files --cached --others --exclude-standard '*.sh' | sort -u)
    shellcheck --external-sources "${shell_scripts[@]}"
else
    log "ShellCheck unavailable; syntax checks still ran"
fi

log "checking structured config"
while IFS= read -r json_file; do
    jq empty "$json_file"
done < <(git ls-files --cached --others --exclude-standard '*.json' | sort -u)
python3 - <<'PY'
from pathlib import Path
import tomllib
for path in Path('.').rglob('*.toml'):
    if '.git' not in path.parts:
        with path.open('rb') as stream:
            tomllib.load(stream)
PY

log "checking submodule metadata"
mapfile -t gitlinks < <(comm -23 \
    <(git ls-files -s | awk '$1 == "160000" { print $4 }' | sort) \
    <(git diff HEAD --name-only --diff-filter=D | sort) \
)
mapfile -t module_paths < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{ print $2 }' | sort)
[[ "${gitlinks[*]}" == "${module_paths[*]}" ]] || {
    printf 'gitlinks: %s\n.gitmodules: %s\n' "${gitlinks[*]}" "${module_paths[*]}" >&2
    fail "gitlinks and .gitmodules paths differ"
}

for gitlink in "${gitlinks[@]}"; do
    [[ "$gitlink" != tmux/.tmux/plugins/* ]] || fail "tmux plugins must be managed by TPM, not Git submodules"
done

for generated in \
    dunst/.config/dunst/dunstrc \
    kitty/.config/kitty/theme.conf \
    polybar/.config/polybar/config.ini \
    rofi/.config/rofi/config.rasi \
    themes/.config/themes/current; do
    if git ls-files --error-unmatch "$generated" >/dev/null 2>&1 && [[ -e "$generated" || -L "$generated" ]]; then
        fail "generated file is tracked: $generated"
    fi
done

log "checking command entry points"
./install.sh --help >/dev/null
./update.sh --help >/dev/null
[[ -x install.sh && -x update.sh && -x install/deploy.sh ]] || fail "entry-point scripts must be executable"

log "checking tmux config"
tmux_socket="dotfiles-verify-$$"
tmux -L "$tmux_socket" -f "$ROOT/tmux/.tmux.conf" new-session -d -s verify
tmux -L "$tmux_socket" has-session -t verify
tmux -L "$tmux_socket" kill-server

if command -v nvim >/dev/null; then
    log "checking Neovim qkt filetype"
    nvim --headless -u NONE \
        --cmd "set runtimepath^=$ROOT/nvim/.config/nvim" \
        --cmd 'filetype on' \
        --cmd 'syntax on' \
        '+edit /tmp/dotfiles-verify.qkt' \
        '+if &filetype !=# "qkt" | cquit 1 | endif' \
        '+quit'
fi

if [[ "${DOTFILES_VERIFY_SKIP_INTEGRATION:-false}" != "true" ]]; then
    log "running deployment integration tests"
    "$ROOT/tests/test-deploy.sh"
    "$ROOT/tests/test-themes.sh"
    "$ROOT/tests/test-update.sh"
fi

log "all checks passed"
