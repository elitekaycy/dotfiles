#!/usr/bin/env bash
# Restart Polybar when the active RandR monitor layout changes.
set -Eeuo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
launcher="$config_home/polybar/launch.sh"
display_setup="$config_home/i3/display-setup.sh"

if command -v flock >/dev/null; then
    exec 201>"${XDG_RUNTIME_DIR:-/tmp}/polybar-monitor-watch-${UID}.lock"
    flock -n 201 || exit 0
fi

snapshot_monitors() {
    if command -v polybar >/dev/null; then
        polybar --list-monitors | sort
    elif command -v xrandr >/dev/null; then
        xrandr --query | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ { print $0 }' | sort
    else
        return 1
    fi
}

arrange_displays() {
    [[ -x "$display_setup" ]] || return 0
    "$display_setup" >/dev/null 2>&1 || true
}

restart_polybar() {
    [[ -x "$launcher" ]] || exit 0
    (
        exec 201>&-
        "$launcher" >/dev/null 2>&1
    ) &
}

last_snapshot="$(snapshot_monitors 2>/dev/null || true)"

if command -v xev >/dev/null; then
    while IFS= read -r event; do
        case "$event" in
            *RRScreenChangeNotify*|*RROutputChangeNotify*)
                sleep 1
                arrange_displays
                current_snapshot="$(snapshot_monitors 2>/dev/null || true)"
                [[ "$current_snapshot" == "$last_snapshot" ]] && continue
                last_snapshot="$current_snapshot"
                restart_polybar
                ;;
        esac
    done < <(exec 201>&-; xev -root -event randr 2>/dev/null)
else
    while sleep 5; do
        arrange_displays
        current_snapshot="$(snapshot_monitors 2>/dev/null || true)"
        [[ "$current_snapshot" == "$last_snapshot" ]] && continue
        last_snapshot="$current_snapshot"
        restart_polybar
    done
fi
