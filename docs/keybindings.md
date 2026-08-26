# Keybindings

`Mod` = Super. Shown live with `Mod+Shift+/` (`dots-keys`). Existing bindings are never changed; new features get new chords.

## Launchers and menus

| Key | Action |
| --- | --- |
| `Mod+Return` | Kitty |
| `Mod+d` | Rofi app launcher |
| `Mod+Alt+Space` | **Search everything** — actions + apps (`dots-menu`) |
| `Mod+v` | Clipboard history (greenclip) |
| `Mod+Shift+/` | Keybinding reference |
| `Mod+z` / `Mod+b` | Zen browser / Firefox |
| `Mod+m` | ncspot |
| `Mod+Shift+a` / `Mod+Shift+v` | ani-cli / lobster |
| `Mod+Shift+w` | tmux session `work` |
| `Mod+Shift+t` | tmux session `scalestash` |

## Theme and wallpaper

| Key | Action |
| --- | --- |
| `Mod+t` or `Mod+Ctrl+Shift+Space` | Theme picker |
| `Mod+Ctrl+t` | Next theme |
| `Mod+Shift+b` | Wallpaper picker |
| `Mod+Ctrl+Space` | Next wallpaper (current theme) |

## Windows and workspaces

| Key | Action |
| --- | --- |
| `Mod+h/j/k/l` or arrows | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` or `Mod+Shift+arrows` | Move window |
| `Mod+1…0` / `Mod+Shift+1…0` | Go to / move to workspace 1…10 |
| `Mod+a` / `Mod+-` | Split vertical / horizontal |
| `Mod+s` / `Mod+w` / `Mod+e` | Stacking / tabbed / toggle split |
| `Mod+=` | Toggle split layout |
| `Mod+f` | Fullscreen (hides the bar) |
| `Mod+Shift+m` | Maximize but keep the bar: no gaps/borders on this workspace (toggle) |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Space` | Focus tiling ↔ floating |
| `Mod+c` | Centre floating window |
| `Mod+Shift+q` | Close window |
| `Mod+Shift+r` | Restart i3 |

## System

| Key | Action |
| --- | --- |
| `Mod+Escape` | Lock |
| `Mod+g` | Grep search (`dots-grep`, opens in Kitty) |
| `Mod+i` | Quick system stats (`dots-stats`) |
| `Mod+Shift+s` / `Mod+Shift+f` / `Mod+Shift+c` | Screenshot area / full / area→clipboard |
| `Mod+Ctrl+r` | Screen recording: start, then toggle pause/resume (`dots-record`) |
| `Mod+Ctrl+Shift+r` | Screen recording: stop and save to `~/Videos` |
| `XF86 brightness / volume / media keys` | brightnessctl, pactl, playerctl |

Polybar (icons only, left → right): `≡` menu (click: `dots-menu`, right-click: Kitty) · workspaces 1–5 always, 6–10 when used (dot = active, click to switch) · clock (click: `dots-menu`) · tray · bluetooth (`dots-bluetooth`) · wifi (`dots-wifi`) · audio (click: `pavucontrol`, right-click: mute, scroll: volume) · cpu / memory (click: `dots-stats`, right-click: full `btop`) · battery (`dots-power`).

## tmux (prefix `Ctrl+g`)

| Key | Action |
| --- | --- |
| `Ctrl+g p` then `n/r/l/u/d` | Split right/right/left/up/down in the current directory |
| `Ctrl+g t` then `n/h/l` | New window / previous / next |
| `Ctrl+h/j/k/l` | Move between panes and Neovim splits |
| `Alt+H` / `Alt+L` | Previous / next window |
| `Ctrl+g [` | Copy mode (vi keys; `v` select, `y` yank) |

Shell: `tn <name>` new, `ta <name>` attach, `tl` list, `tk <name>` kill.
