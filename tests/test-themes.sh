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

# Stand-in for the user-writable slots ./install.sh login creates in the SDDM theme.
SDDM_DIR="$TEST_HOME/sddm-theme"
mkdir -p "$SDDM_DIR/Themes" "$SDDM_DIR/Backgrounds/dotfiles"
: > "$SDDM_DIR/Themes/dotfiles.conf"

for theme_file in "$ROOT"/themes/.config/themes/themes/*.conf; do
    theme_id="$(basename "$theme_file" .conf)"
    HOME="$TEST_HOME" \
    XDG_CONFIG_HOME="$TEST_HOME/.config" \
    XDG_STATE_HOME="$TEST_HOME/.local/state" \
    DOTFILES_SDDM_THEME_DIR="$SDDM_DIR" \
        "$TEST_HOME/.local/bin/dots-theme-set" --no-reload "$theme_id"
    [[ "$(<"$TEST_HOME/.local/state/dotfiles/theme")" == "$theme_id" ]]
    grep -q '^Background="Backgrounds/dotfiles/wallpaper\.' "$SDDM_DIR/Themes/dotfiles.conf" || {
        printf 'test-themes: login screen not rendered for %s\n' "$theme_id" >&2
        exit 1
    }
    [[ -n "$(find "$SDDM_DIR/Backgrounds/dotfiles" -name 'wallpaper.*')" ]]
    if grep -R '{{[A-Z_]*}}' \
        "$TEST_HOME/.config/polybar/config.ini" \
        "$TEST_HOME/.config/kitty/theme.conf" \
        "$TEST_HOME/.config/dunst/dunstrc" \
        "$TEST_HOME/.config/rofi/config.rasi" \
        "$TEST_HOME/.config/i3/theme.conf" \
        "$TEST_HOME/.config/tmux/theme.conf" \
        "$SDDM_DIR/Themes/dotfiles.conf"; then
        printf 'test-themes: unresolved template variable in %s\n' "$theme_id" >&2
        exit 1
    fi
done

printf 'test-themes: passed\n'
