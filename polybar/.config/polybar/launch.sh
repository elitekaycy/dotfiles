#!/usr/bin/env bash
# Polybar launch script - multi-monitor support
set -Eeuo pipefail

# Prevent concurrent theme/startup reloads without leaving stale lock files.
if command -v flock >/dev/null; then
    exec 200>"${XDG_RUNTIME_DIR:-/tmp}/polybar-${UID}.lock"
    flock -n 200 || exit 0
fi

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/polybar"
mkdir -p "$log_dir"

display_setup="${XDG_CONFIG_HOME:-$HOME/.config}/i3/display-setup.sh"
if [[ -x "$display_setup" ]]; then
    "$display_setup" >/dev/null 2>&1 || true
    sleep 0.3
fi

get_active_monitors() {
    if command -v polybar >/dev/null; then
        polybar --list-monitors | cut -d: -f1
    elif command -v xrandr >/dev/null; then
        xrandr --query | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ { print $1 }'
    else
        return 1
    fi
}

get_monitor_width() {
    local monitor="$1"

    if command -v polybar >/dev/null; then
        polybar --list-monitors | awk -v monitor="$monitor" '
            $1 == monitor ":" {
                split($2, dimensions, "x")
                print dimensions[1]
                exit
            }
        '
    elif command -v xrandr >/dev/null; then
        xrandr --query | awk -v monitor="$monitor" '
            $1 == monitor && / connected/ {
                for (i = 1; i <= NF; i++) {
                    if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
                        split($i, dimensions, "x")
                        print dimensions[1]
                        exit
                    }
                }
            }
        '
    fi
}

get_bar_geometry() {
    local monitor="$1"
    local monitor_width
    local bar_width
    local bar_offset

    monitor_width="$(get_monitor_width "$monitor")"
    if [[ "$monitor_width" =~ ^[0-9]+$ && "$monitor_width" -gt 0 ]]; then
        bar_width=$((monitor_width * 48 / 100))
        bar_offset=$(((monitor_width - bar_width) / 2))
        printf '%s %s\n' "$bar_width" "$bar_offset"
    else
        printf '48%% 26%%\n'
    fi
}

# Terminate this user's running Polybar instances.
polybar-msg cmd quit >/dev/null 2>&1 || true
pkill -u "$UID" -x polybar 2>/dev/null || true

# Wait until all processes have been shut down.
for _ in {1..30}; do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.1
done

if pgrep -u "$UID" -x polybar >/dev/null; then
    pkill -9 -u "$UID" -x polybar 2>/dev/null || true
    sleep 0.5
fi

mapfile -t monitors < <(get_active_monitors | awk 'NF' | sort -u)

if ((${#monitors[@]} == 0)); then
    (
        exec 200>&-
        setsid -f polybar main >>"$log_dir/main.log" 2>&1
    )
else
    for monitor in "${monitors[@]}"; do
        read -r bar_width bar_offset < <(get_bar_geometry "$monitor")
        (
            exec 200>&-
            MONITOR="$monitor" BAR_WIDTH="$bar_width" BAR_OFFSET_X="$bar_offset" \
                setsid -f polybar main >>"$log_dir/$monitor.log" 2>&1
        )
    done
fi
