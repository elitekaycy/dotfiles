# Commands

All live in `bin/.local/bin/` and are on `PATH` as `~/.local/bin/dots-*`. i3, Polybar and the shell all call these — there is no logic scattered under `~/.config/<app>/`.

| Command | Does |
| --- | --- |
| `dots-menu` | **The search.** Every system action and every app in one rofi list. Type `shutdown`, `brightness`, `wifi`, `volume`, `theme`, `firefox`… Enter runs it. Hidden keywords match too (`poweroff`, `dim`, `screen`, `sleep`) |
| `dots-actions` | The action list behind `dots-menu` (rofi script mode); add a row there to add a searchable action |
| `dots-brightness up\|down\|<percent>` | Screen brightness with an on-screen bar |
| `dots-power [lock\|logout\|suspend\|hibernate\|reboot\|shutdown]` | Power menu, or jump straight to one action (destructive ones confirm) |
| `dots-theme-menu` | Rofi theme picker; type a name or `dark` / `light` to filter |
| `dots-theme-set [--no-reload] <id>` | Render + apply a theme (`dots-theme-set nord`) |
| `dots-theme-next` | Cycle to the next theme |
| `dots-theme-current` | Print the selected theme id |
| `dots-bg-menu` | Rofi wallpaper picker (current theme first, then `shared/`, then the rest) |
| `dots-bg-next` | Next wallpaper within the current theme + `shared/` |
| `dots-bg-set [path]` | Set a wallpaper on every monitor; no arg restores the last one |
| `dots-session <name>` / `--menu` | Create/attach tmux session `main`, `work`, `scalestash`, or any name; `--menu` picks in Rofi |
| `dots-keys` | Searchable list of every i3 keybinding |
| `dots-wifi` / `dots-bluetooth` | Rofi network menus (also opened by clicking the Polybar modules) |
| `dots-screenshot area\|full\|clip` | Flameshot |
| `dots-record start\|stop\|pause\|resume\|toggle` | Screen recording via ffmpeg (X11 grab + system audio), saved to `~/Videos`; keeps recording straight through a lock |
| `dots-lock` | Lock: blurred desktop, clock and ring in the theme colours (i3lock-color; plain i3lock fallback) |
| `dots-grep [query] [dir]` | Live content search: ripgrep results fuzzy-filtered in fzf with a `bat` preview; Enter opens the file in `$EDITOR` at that line |
| `dots-stats` | Quick stats dropdown (rofi): CPU, memory, disk, temperature, battery, uptime, kernel |
| `dots-login-sync` | Re-render the SDDM login screen from the theme + current wallpaper (run automatically on theme/wallpaper change) |
| `dots-monitors save\|apply\|arrange\|forget` | Per-output monitor layouts — see [desktop.md](./desktop.md#monitors) |
| `dots-secret <verb> <name>` | `pass`/keyring-backed secrets — see [secrets.md](./secrets.md) |
| `dots-darkmode` | Force dark GTK UI and dark web content in every Zen/Firefox profile |

Adding a new one-off action? Add a row to `dots-actions` so it shows up in `dots-menu` without a new keybinding.
