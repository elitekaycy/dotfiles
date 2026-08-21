#!/usr/bin/env bash
#
# Rofi Wallpaper Picker - Select and apply wallpapers
#

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Check if there are any wallpapers
shopt -s nullglob
wallpapers=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp})
shopt -u nullglob

if [[ ${#wallpapers[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR" -i dialog-warning
    exit 1
fi

# Build menu with image previews (filename only)
build_menu() {
    for wp in "${wallpapers[@]}"; do
        basename "$wp"
    done
}

# Show rofi menu
selected=$(build_menu | rofi -dmenu -i -p "Wallpaper" \
    -theme-str 'window {width: 400px;}' \
    -theme-str 'listview {lines: 12;}' \
    -no-custom)

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Apply wallpaper
wallpaper_path="$WALLPAPER_DIR/$selected"

if [[ -f "$wallpaper_path" ]]; then
    echo "$wallpaper_path" > "$CONFIG_HOME/current-wallpaper"
    if [[ -x "$CONFIG_HOME/i3/wallpaper-setup.sh" ]]; then
        "$CONFIG_HOME/i3/wallpaper-setup.sh" "$wallpaper_path"
    else
        feh --bg-fill "$wallpaper_path"
    fi
    notify-send "Wallpaper" "Applied: $selected" -i preferences-desktop-wallpaper
else
    notify-send "Wallpaper Picker" "File not found: $selected" -i dialog-error
fi
