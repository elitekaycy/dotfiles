#!/usr/bin/env bash
# Rofi power menu

lock_screen() {
    "${XDG_CONFIG_HOME:-$HOME/.config}/themes/scripts/lock.sh"
}

# Options with icons
lock="  Lock"
logout="󰍃  Logout"
suspend="󰤄  Suspend"
hibernate="󰒲  Hibernate"
reboot="  Reboot"
shutdown="  Shutdown"

# Show rofi menu
chosen=$(echo -e "$lock\n$logout\n$suspend\n$hibernate\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power" -theme-str '
window { width: 22em; }
listview { lines: 6; }
')

# Confirm for destructive actions
confirm_action() {
    local action=$1
    local confirm
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Confirm $action?" -theme-str '
window { width: 22em; }
listview { lines: 2; }
')
    [[ "$confirm" == "Yes" ]]
}

# Handle selection
case "$chosen" in
    "$lock")
        lock_screen
        ;;
    "$logout")
        confirm_action "logout" && i3-msg exit
        ;;
    "$suspend")
        lock_screen && systemctl suspend
        ;;
    "$hibernate")
        lock_screen && systemctl hibernate
        ;;
    "$reboot")
        confirm_action "reboot" && systemctl reboot
        ;;
    "$shutdown")
        confirm_action "shutdown" && systemctl poweroff
        ;;
esac
