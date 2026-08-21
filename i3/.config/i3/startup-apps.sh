#!/usr/bin/env bash
# Start session apps only when they are not already running.
set -Eeuo pipefail

ws1="1:  browser"
ws2="2:  work"

run_on_workspace() {
    local workspace="$1"
    shift

    i3-msg "workspace number $workspace" >/dev/null
    i3-msg "exec --no-startup-id $*" >/dev/null
}

has_process() {
    pgrep -u "$UID" "$@" >/dev/null 2>&1
}

if ! has_process -f 'kitty .*dots-session main'; then
    run_on_workspace "$ws1" "kitty -e $HOME/.local/bin/dots-session main"
fi

if ! has_process -x firefox; then
    run_on_workspace "$ws2" firefox
fi

if ! has_process -f '(^|/)(google-chrome|chrome)( .*--class=SlackWebApp|.*--app=https://app\.slack\.com)'; then
    run_on_workspace "$ws2" "google-chrome --app=https://app.slack.com --class=SlackWebApp --user-data-dir=$HOME/.local/share/webapps/slack-chrome-profile --no-first-run --disable-infobars"
fi
