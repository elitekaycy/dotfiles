#!/usr/bin/env bash
# Lock the screen with the active theme's background colour.
set -Eeuo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

BG="#1a1b26"
theme_id="$(cat "$STATE_DIR/theme" 2>/dev/null || true)"
theme_file="$CONFIG_HOME/themes/themes/${theme_id:-tokyo-night}.conf"
if [[ -f "$theme_file" ]]; then
    source "$theme_file"
fi

exec i3lock -c "${BG#\#}" "$@"
