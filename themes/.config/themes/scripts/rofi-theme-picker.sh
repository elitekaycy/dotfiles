#!/usr/bin/env bash
# Rofi theme picker. Type to filter by name or by "dark"/"light".
set -Eeuo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
THEMES_DIR="$CONFIG_HOME/themes"
THEMES_CONF_DIR="$THEMES_DIR/themes"
SCRIPTS_DIR="$THEMES_DIR/scripts"
CURRENT_THEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"

current="$(cat "$CURRENT_THEME_FILE" 2>/dev/null || true)"

theme_ids=()
rows=()
for theme_file in "$THEMES_CONF_DIR"/*.conf; do
    [[ -f "$theme_file" ]] || continue
    theme_id="$(basename "$theme_file" .conf)"
    theme_name="$theme_id"
    theme_type="dark"

    while IFS='=' read -r key value; do
        value="${value%\"}"; value="${value#\"}"
        case "$key" in
            THEME_NAME) theme_name="$value" ;;
            THEME_TYPE) theme_type="$value" ;;
        esac
    done < "$theme_file"

    icon=""
    [[ "$theme_type" == "light" ]] && icon=""
    marker=""
    [[ "$theme_id" == "$current" ]] && marker="  "

    theme_ids+=("$theme_id")
    rows+=("$icon  $theme_name$marker  ($theme_type)")
done

[[ ${#rows[@]} -gt 0 ]] || exit 0

index="$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -p "Theme" \
    -format 'i' -no-custom \
    -theme-str 'window {width: 26em;}' \
    -theme-str 'listview {lines: 10;}')" || exit 0

[[ -n "$index" ]] || exit 0
exec "$SCRIPTS_DIR/apply-theme.sh" "${theme_ids[$index]}"
