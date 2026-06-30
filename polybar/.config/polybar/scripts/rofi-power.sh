#!/bin/bash
# Rofi Power Menu - Tokyo Night themed

# Options with icons
lock="  Lock"
logout="󰍃  Logout"
suspend="󰤄  Suspend"
hibernate="󰒲  Hibernate"
reboot="  Reboot"
shutdown="  Shutdown"

# Show rofi menu
chosen=$(echo -e "$lock\n$logout\n$suspend\n$hibernate\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power" -theme-str '
window { width: 200px; }
listview { lines: 6; }
')

# Confirm for destructive actions
confirm_action() {
    local action=$1
    local confirm
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Confirm $action?" -theme-str '
window { width: 200px; }
listview { lines: 2; }
')
    [[ "$confirm" == "Yes" ]]
}

# Handle selection
case "$chosen" in
    "$lock")
        i3lock -c 1a1b26
        ;;
    "$logout")
        confirm_action "logout" && i3-msg exit
        ;;
    "$suspend")
        i3lock -c 1a1b26 && systemctl suspend
        ;;
    "$hibernate")
        i3lock -c 1a1b26 && systemctl hibernate
        ;;
    "$reboot")
        confirm_action "reboot" && systemctl reboot
        ;;
    "$shutdown")
        confirm_action "shutdown" && systemctl poweroff
        ;;
esac
