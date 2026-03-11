#!/usr/bin/env bash
#
# Rofi Theme Picker - Select and apply themes via rofi
#

THEMES_DIR="$HOME/.config/themes"
THEMES_CONF_DIR="$THEMES_DIR/themes"
SCRIPTS_DIR="$THEMES_DIR/scripts"
CURRENT_THEME_FILE="$THEMES_DIR/current"

# Get current theme
CURRENT=""
if [[ -f "$CURRENT_THEME_FILE" ]]; then
    CURRENT=$(cat "$CURRENT_THEME_FILE")
fi

# Build menu items from theme files
# Format: "Theme Name (type)"
build_menu() {
    for theme_file in "$THEMES_CONF_DIR"/*.conf; do
        [[ -f "$theme_file" ]] || continue

        local theme_id
        theme_id=$(basename "$theme_file" .conf)

        # Source the theme to get the display name and type
        local theme_name=""
        local theme_type=""
        while IFS='=' read -r key value; do
            # Remove leading/trailing whitespace and quotes
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            value="${value#[[:space:]]}"
            value="${value%[[:space:]]}"

            case "$key" in
                THEME_NAME*) theme_name="$value" ;;
                THEME_TYPE*) theme_type="$value" ;;
            esac
        done < "$theme_file"

        # Default values if not found
        [[ -z "$theme_name" ]] && theme_name="$theme_id"
        [[ -z "$theme_type" ]] && theme_type="dark"

        # Add marker for current theme
        local marker=""
        [[ "$theme_id" == "$CURRENT" ]] && marker=" *"

        # Icon based on theme type
        local icon=""
        [[ "$theme_type" == "light" ]] && icon="" || icon=""

        echo "$icon  $theme_name$marker|$theme_id"
    done
}

# Show rofi menu
selected=$(build_menu | rofi -dmenu -i -p "Theme" \
    -theme-str 'window {width: 400px;}' \
    -theme-str 'listview {lines: 10;}' \
    -format 's' \
    -no-custom)

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Extract theme ID from selection (after the |)
theme_id="${selected##*|}"

# Apply the selected theme
if [[ -n "$theme_id" ]]; then
    "$SCRIPTS_DIR/apply-theme.sh" "$theme_id"
fi
