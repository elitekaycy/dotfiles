#!/usr/bin/env bash
# React to monitor changes:
#   - a monitor is plugged/unplugged  -> apply the saved layout for that set
#   - the geometry changes (arandr, xrandr, the above) -> restart Polybar
# Layouts are only applied on hotplug so a manual arandr change is never undone.
set -Eeuo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
launcher="$config_home/polybar/launch.sh"

if command -v flock >/dev/null; then
    exec 201>"${XDG_RUNTIME_DIR:-/tmp}/polybar-monitor-watch-${UID}.lock"
    flock -n 201 || exit 0
fi

connected_set() { xrandr --query | awk '/ connected/ { print $1 }' | sort | paste -sd+ -; }
geometry() { polybar --list-monitors 2>/dev/null | sort; }

restart_polybar() {
    [[ -x "$launcher" ]] || return 0
    (
        exec 201>&-
        "$launcher" >/dev/null 2>&1
    ) &
}

last_set="$(connected_set)"
last_geometry="$(geometry)"

handle_change() {
    sleep 1
    local current_set current_geometry
    current_set="$(connected_set)"
    if [[ "$current_set" != "$last_set" ]]; then
        last_set="$current_set"
        "$HOME/.local/bin/dots-monitors" apply >/dev/null 2>&1 || true
        sleep 1
    fi
    current_geometry="$(geometry)"
    [[ "$current_geometry" == "$last_geometry" ]] && return 0
    last_geometry="$current_geometry"
    restart_polybar
}

if command -v xev >/dev/null; then
    while IFS= read -r event; do
        case "$event" in
            *RRScreenChangeNotify*|*RROutputChangeNotify*) handle_change ;;
        esac
    done < <(exec 201>&-; xev -root -event randr 2>/dev/null)
else
    while sleep 5; do handle_change; done
fi
