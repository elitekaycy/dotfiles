#!/bin/bash
# Rofi WiFi menu - Tokyo Night themed

# Get current connection
current=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Options
toggle_wifi="Toggle WiFi"
scan_wifi="Scan Networks"
disconnect="Disconnect"

# Get list of available networks
networks=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list | grep -v '^--' | sort -t':' -k2 -rn | uniq)

# Build menu
menu="$toggle_wifi\n$scan_wifi"
[[ -n "$current" ]] && menu="$menu\n$disconnect"
menu="$menu\n---"

while IFS=':' read -r ssid signal security; do
    [[ -z "$ssid" ]] && continue

    # Signal icon
    if [[ $signal -ge 70 ]]; then
        icon="󰤨"
    elif [[ $signal -ge 40 ]]; then
        icon="󰤥"
    else
        icon="󰤟"
    fi

    # Lock icon for secured networks
    [[ -n "$security" && "$security" != "--" ]] && lock="󰌾" || lock=""

    # Mark current connection
    [[ "$ssid" == "$current" ]] && mark="*" || mark=""

    menu="$menu\n$icon $ssid $lock $mark"
done <<< "$networks"

# Show rofi menu
chosen=$(echo -e "$menu" | rofi -dmenu -i -p "WiFi" -theme-str '
window { width: 400px; }
listview { lines: 10; }
')

# Handle selection
case "$chosen" in
    "$toggle_wifi")
        wifi_status=$(nmcli radio wifi)
        if [[ "$wifi_status" == "enabled" ]]; then
            nmcli radio wifi off
            notify-send "WiFi" "Disabled"
        else
            nmcli radio wifi on
            notify-send "WiFi" "Enabled"
        fi
        ;;
    "$scan_wifi")
        nmcli dev wifi rescan
        notify-send "WiFi" "Scanning..."
        ;;
    "$disconnect")
        nmcli dev disconnect wlan0 2>/dev/null || nmcli dev disconnect wlp0s20f3 2>/dev/null
        notify-send "WiFi" "Disconnected"
        ;;
    "---"|"")
        exit 0
        ;;
    *)
        # Extract SSID (remove icons and markers)
        ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ 󰌾.*//' | sed 's/ \*$//' | xargs)

        # Check if already connected
        if [[ "$ssid" == "$current" ]]; then
            notify-send "WiFi" "Already connected to $ssid"
            exit 0
        fi

        # Check if network is saved
        if nmcli -t -f NAME con show | grep -q "^$ssid$"; then
            nmcli con up "$ssid"
        else
            # Ask for password
            password=$(rofi -dmenu -password -p "Password for $ssid")
            if [[ -n "$password" ]]; then
                nmcli dev wifi connect "$ssid" password "$password"
            fi
        fi
        ;;
esac
