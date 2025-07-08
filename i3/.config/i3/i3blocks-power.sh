#!/bin/bash

# Always print the power icon so it's visible on the bar
echo ""

# Wait for click event
read -r click

# Parse the button number (jq makes it clean)
button=$(echo "$click" | jq -r .button)

# If left-click (button 1), power off
if [ "$button" == "1" ]; then
    systemctl poweroff
fi

