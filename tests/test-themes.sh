#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

HOME="$TEST_HOME" \
DOTFILES_TARGET_HOME="$TEST_HOME" \
XDG_CONFIG_HOME="$TEST_HOME/.config" \
XDG_STATE_HOME="$TEST_HOME/.local/state" \
    bash -c 'source "$1/install/setup.sh"; stow_dotfiles; setup_wallpapers' _ "$ROOT"

for theme_file in "$ROOT"/themes/.config/themes/themes/*.conf; do
    theme_id="$(basename "$theme_file" .conf)"
    HOME="$TEST_HOME" \
    XDG_CONFIG_HOME="$TEST_HOME/.config" \
    XDG_STATE_HOME="$TEST_HOME/.local/state" \
        "$TEST_HOME/.config/themes/scripts/apply-theme.sh" --no-reload "$theme_id"
    [[ "$(<"$TEST_HOME/.local/state/dotfiles/theme")" == "$theme_id" ]]
    if grep -R '{{[A-Z_]*}}' \
        "$TEST_HOME/.config/polybar/config.ini" \
        "$TEST_HOME/.config/kitty/theme.conf" \
        "$TEST_HOME/.config/dunst/dunstrc" \
        "$TEST_HOME/.config/rofi/config.rasi" \
        "$TEST_HOME/.config/i3/theme.conf" \
        "$TEST_HOME/.config/tmux/theme.conf"; then
        printf 'test-themes: unresolved template variable in %s\n' "$theme_id" >&2
        exit 1
    fi
done

printf 'test-themes: passed\n'
