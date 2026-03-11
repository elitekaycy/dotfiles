#!/bin/bash
if pgrep -x slack > /dev/null; then
    i3-msg '[class="Slack"] focus' || i3-msg '[class="Slack"] kill'
else
    slack
fi