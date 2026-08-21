#!/usr/bin/env bash
# Omarchy-style workspaces for polybar: 1-5 always shown, 6-10 when in use.
# Dot = focused, number = occupied, dim number = empty, red = urgent.
# Event driven: re-renders on every i3 workspace event (no polling).
set -u

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
theme="$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme" 2>/dev/null || echo tokyo-night)"
FG="#c0caf5"; FG_DIM="#565f89"; RED="#f7768e"
[[ -f "$CONFIG_HOME/themes/themes/$theme.conf" ]] && source "$CONFIG_HOME/themes/themes/$theme.conf"

render() {
    local -A focused=() urgent=() exists=()
    local num="" key value out=""

    while IFS=: read -r key value; do
        case "$key" in
            '"num"') num="$value"; exists[$num]=1 ;;
            '"focused"') [[ "$value" == true ]] && focused[$num]=1 ;;
            '"urgent"') [[ "$value" == true ]] && urgent[$num]=1 ;;
        esac
    done < <(i3-msg -t get_workspaces 2>/dev/null | grep -oE '"(num|focused|urgent)":[a-z0-9]+')

    for n in 1 2 3 4 5 6 7 8 9 10; do
        local label="$n" color="$FG_DIM"
        [[ $n == 10 ]] && label="0"
        if [[ -n "${focused[$n]:-}" ]]; then
            label="󱓻"; color="$FG"
        elif [[ -n "${urgent[$n]:-}" ]]; then
            color="$RED"
        elif [[ -n "${exists[$n]:-}" ]]; then
            color="$FG"
        elif (( n > 5 )); then
            continue
        fi
        out+="%{A1:i3-msg workspace number $n:}%{F$color} $label %{F-}%{A}"
    done
    printf '%s\n' "$out"
}

render
i3-msg -t subscribe -m '["workspace"]' 2>/dev/null | while read -r _; do
    render
done
