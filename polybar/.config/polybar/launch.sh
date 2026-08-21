#!/usr/bin/env bash
# Launch one full-width Polybar per connected monitor.
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

# Terminate this user's running Polybar instances and their tailing scripts.
polybar-msg cmd quit >/dev/null 2>&1 || true
pkill -u "$UID" -x polybar 2>/dev/null || true
pkill -u "$UID" -f 'polybar/scripts/workspaces.sh' 2>/dev/null || true

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
        (
            exec 200>&-
            MONITOR="$monitor" setsid -f polybar main >>"$log_dir/$monitor.log" 2>&1
        )
    done
fi
