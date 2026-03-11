#!/bin/bash
if pgrep -f obsidian > /dev/null; then
    i3-msg '[class="Obsidian"] focus' || i3-msg '[class="Obsidian"] kill'
else
    obsidian
fi