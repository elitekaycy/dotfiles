#!/usr/bin/env bash
#
# Rofi Wallpaper Picker - Select and apply wallpapers
#

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
    feh --bg-fill "$wallpaper_path"
    notify-send "Wallpaper" "Applied: $selected" -i preferences-desktop-wallpaper

    # Save current wallpaper for persistence
    echo "$wallpaper_path" > "$HOME/.config/current-wallpaper"
else
    notify-send "Wallpaper Picker" "File not found: $selected" -i dialog-error
fi
