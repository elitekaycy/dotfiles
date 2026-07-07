#!/bin/bash
# Rofi Bluetooth menu

# Options
toggle_bt="Toggle Bluetooth"
scan_bt="Scan Devices"
disconnect_all="Disconnect All"

# Get bluetooth status
powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

# Get connected devices
connected_devices=$(bluetoothctl devices Connected 2>/dev/null)

# Get paired devices
paired_devices=$(bluetoothctl devices Paired 2>/dev/null)

# Build menu
menu="$toggle_bt\n$scan_bt"
[[ -n "$connected_devices" ]] && menu="$menu\n$disconnect_all"
menu="$menu\n---\nConnected:"

# Add connected devices
while read -r line; do
    [[ -z "$line" ]] && continue
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    menu="$menu\n󰂱 $name [$mac]"
done <<< "$connected_devices"

menu="$menu\n---\nPaired:"

# Add paired devices (not connected)
while read -r line; do
    [[ -z "$line" ]] && continue
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)

    # Skip if already connected
    echo "$connected_devices" | grep -q "$mac" && continue

    menu="$menu\n󰂯 $name [$mac]"
done <<< "$paired_devices"

# Show rofi menu
chosen=$(echo -e "$menu" | rofi -dmenu -i -p "Bluetooth" -theme-str '
window { width: 34em; }
listview { lines: 12; }
')

# Handle selection
case "$chosen" in
    "$toggle_bt")
        if [[ "$powered" == "yes" ]]; then
            bluetoothctl power off
            notify-send "Bluetooth" "Disabled"
        else
            bluetoothctl power on
            notify-send "Bluetooth" "Enabled"
        fi
        ;;
    "$scan_bt")
        notify-send "Bluetooth" "Scanning for 10 seconds..."
        bluetoothctl --timeout 10 scan on &
        ;;
    "$disconnect_all")
        while read -r line; do
            mac=$(echo "$line" | awk '{print $2}')
            bluetoothctl disconnect "$mac" 2>/dev/null
        done <<< "$connected_devices"
        notify-send "Bluetooth" "Disconnected all devices"
        ;;
    "---"|"Connected:"|"Paired:"|"")
        exit 0
        ;;
    *)
        # Extract MAC address
        mac=$(echo "$chosen" | grep -oE '[0-9A-F]{2}(:[0-9A-F]{2}){5}')
        name=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ \[.*$//')

        if [[ -z "$mac" ]]; then
            exit 0
        fi

        # Check if connected
        if echo "$connected_devices" | grep -q "$mac"; then
            # Disconnect
            bluetoothctl disconnect "$mac"
            notify-send "Bluetooth" "Disconnected from $name"
        else
            # Connect
            notify-send "Bluetooth" "Connecting to $name..."
            bluetoothctl connect "$mac"
        fi
        ;;
esac
