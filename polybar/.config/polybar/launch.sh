#!/bin/bash
# Polybar launch script - Multi-monitor support

# Prevent concurrent launches
LOCKFILE="/tmp/polybar-launch.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 1

# Terminate all running polybar instances
killall -q polybar
pkill -x polybar 2>/dev/null

# Wait until all processes have been shut down (max 3 seconds)
timeout=3
while pgrep -u $UID -x polybar >/dev/null && [ $timeout -gt 0 ]; do
    sleep 0.5
    ((timeout--))
done

# Force kill if still running
pkill -9 -x polybar 2>/dev/null
sleep 0.2

# Launch polybar on all connected monitors
if type "xrandr" &>/dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar main 2>&1 | tee -a /tmp/polybar-$m.log & disown
    done
else
    polybar main 2>&1 | tee -a /tmp/polybar.log & disown
fi
