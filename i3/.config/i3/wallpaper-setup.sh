#!/usr/bin/env bash
# Apply the selected wallpaper to every active monitor.
set -Eeuo pipefail

command -v feh >/dev/null || exit 0

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
wallpaper="${1:-}"

if [[ -z "$wallpaper" ]]; then
    if [[ -f "$config_home/current-wallpaper" ]]; then
        wallpaper="$(<"$config_home/current-wallpaper")"
    else
        wallpaper="$HOME/Pictures/wallpapers/tokyo-night.jpg"
    fi
fi

[[ -f "$wallpaper" ]] || exit 0

monitor_count=1
if command -v polybar >/dev/null; then
    monitor_count="$(polybar --list-monitors 2>/dev/null | awk 'END { print NR ? NR : 1 }')"
elif command -v xrandr >/dev/null; then
    monitor_count="$(xrandr --query | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ { count++ } END { print count ? count : 1 }')"
fi

wallpapers=()
for ((i = 0; i < monitor_count; i++)); do
    wallpapers+=("$wallpaper")
done

feh --bg-fill "${wallpapers[@]}"
