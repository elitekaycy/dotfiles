#!/usr/bin/env bash
# Arrange connected displays as one extended desktop before bars are launched.
set -Eeuo pipefail

command -v xrandr >/dev/null || exit 0

mapfile -t connected_outputs < <(xrandr --query | awk '/ connected/ { print $1 }')
((${#connected_outputs[@]} > 0)) || exit 0

primary_output="$(xrandr --query | awk '/ connected primary/ { print $1; exit }')"

if [[ -z "$primary_output" ]]; then
    for output in "${connected_outputs[@]}"; do
        case "$output" in
            eDP*|LVDS*)
                primary_output="$output"
                break
                ;;
        esac
    done
fi

[[ -n "$primary_output" ]] || primary_output="${connected_outputs[0]}"

args=(--output "$primary_output" --auto --primary)
previous_output="$primary_output"

for output in "${connected_outputs[@]}"; do
    [[ "$output" != "$primary_output" ]] || continue
    args+=(--output "$output" --auto --right-of "$previous_output")
    previous_output="$output"
done

xrandr "${args[@]}" >/dev/null 2>&1 || true
