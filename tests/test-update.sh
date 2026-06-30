#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

printf 'existing shell config\n' > "$TEST_HOME/.bashrc"
HOME="$TEST_HOME" \
DOTFILES_TARGET_HOME="$TEST_HOME" \
XDG_STATE_HOME="$TEST_HOME/.local/state" \
XDG_CONFIG_HOME="$TEST_HOME/.config" \
XDG_RUNTIME_DIR="$TEST_HOME/.run" \
DOTFILES_VERIFY_SKIP_INTEGRATION=true \
    "$ROOT/update.sh" --local --configs-only --no-reload

[[ -L "$TEST_HOME/.bashrc" ]]
[[ -f "$TEST_HOME/.config/polybar/config.ini" && ! -L "$TEST_HOME/.config/polybar/config.ini" ]]
[[ -f "$TEST_HOME/.config/kitty/theme.conf" && ! -L "$TEST_HOME/.config/kitty/theme.conf" ]]
[[ "$(<"$TEST_HOME/.local/state/dotfiles/theme")" == "tokyo-night" ]]
find "$TEST_HOME/.local/state/dotfiles/backups" -path '*/.bashrc' -type f -print -quit | grep -q .

printf 'test-update: passed\n'
