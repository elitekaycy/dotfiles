#!/bin/bash
# Network status for polybar

# Check for WiFi
wifi_status=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
if [[ -n "$wifi_status" ]]; then
    signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\*' | cut -d':' -f2)
    if [[ $signal -ge 70 ]]; then
        icon="󰤨"
    elif [[ $signal -ge 40 ]]; then
        icon="󰤥"
    else
        icon="󰤟"
    fi
    if [[ ${#wifi_status} -gt 12 ]]; then
        wifi_status="${wifi_status:0:12}..."
    fi
    echo "$icon $wifi_status"
    exit 0
fi

# Check for Ethernet
eth_status=$(ip addr show 2>/dev/null | grep -E "enp|eth" | grep "state UP")
if [[ -n "$eth_status" ]]; then
    echo "󰈀 LAN"
    exit 0
fi

# No connection
echo "󰤭 Offline"
