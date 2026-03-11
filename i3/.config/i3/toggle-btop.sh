#!/bin/bash
if pgrep -f 'btop' > /dev/null; then
    i3-msg '[class="Btop"] focus' || i3-msg '[class="Btop"] kill'
else
    kitty --class Btop -e btop
fi