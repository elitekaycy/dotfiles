#!/bin/bash
if pgrep -f 'kitty.*floating-terminal' > /dev/null; then
    i3-msg '[instance="floating-terminal"] focus' || i3-msg '[instance="floating-terminal"] kill'
else
    kitty --name floating-terminal -e ~/.config/i3/fly-tmux-session.sh
fi