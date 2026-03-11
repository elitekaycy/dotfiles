#!/bin/bash
if pgrep -x spotify > /dev/null; then
    i3-msg '[class="Spotify"] focus' || i3-msg '[class="Spotify"] kill'
else
    spotify
fi