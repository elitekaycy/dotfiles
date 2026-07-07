#!/bin/bash
# Bluetooth status for polybar

# Check if bluetooth is powered on
powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [[ "$powered" != "yes" ]]; then
    echo "󰂲"
    exit 0
fi

# Check for connected devices
connected=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)

if [[ -n "$connected" ]]; then
    echo "󰂱"
else
    echo "󰂯"
fi
