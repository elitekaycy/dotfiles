# Monitors

Layouts are remembered **per set of connected outputs** in `~/.config/monitors/<outputs>.sh` (e.g. `eDP-1-2+HDMI-0.sh`, plain xrandr, editable).

- Plug a monitor in → the saved layout for that combination is applied; if none exists, laptop screen primary with the others to its right.
- Arranging with arandr (or xrandr) is never undone: the watcher only re-applies layouts on hotplug, and restarts Polybar on any geometry change.
- Search `monitors` in `Mod+Alt+Space`: **arrange** (opens arandr and saves when it closes), **save layout**, **reset layout**.

```bash
dots-monitors save      # remember the current layout for these outputs
dots-monitors apply     # what i3 and the hotplug watcher run
dots-monitors arrange   # arandr, then save
dots-monitors forget    # back to the default arrangement
```
