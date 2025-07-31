#!/usr/bin/env bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

MONITOR=DP-2 polybar --reload kaycy &
MONITOR=eDP-2 polybar --reload kaycy &
