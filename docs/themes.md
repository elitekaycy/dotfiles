# Themes

Available: `matte-black` (darkest, Omarchy palette) `akatsuki` (black & blood red) `nebula` (JWST Tarantula Nebula) `tokyo-night` `tokyo-night-light` `catppuccin-mocha` `catppuccin-latte` `dracula` `gruvbox-dark` `gruvbox-light` `nord` `nord-light`

What one theme drives:

| App | Rendered file | How it is picked up |
| --- | --- | --- |
| Polybar | `~/.config/polybar/config.ini` | bar restarted |
| Kitty | `~/.config/kitty/theme.conf` | `include theme.conf`; live via remote control |
| Dunst | `~/.config/dunst/dunstrc` | daemon restarted |
| Rofi | `~/.config/rofi/config.rasi` | next launch |
| i3 | `~/.config/i3/theme.conf` | `include` in i3 config; `i3-msg reload` |
| tmux | `~/.config/tmux/theme.conf` | `source-file` in `.tmux.conf`; live reload |
| pvim | `~/.local/share/nvim/pvim_theme.txt` | read on startup |
| Lockscreen | — | `dots-lock` reads the theme colours at lock time |
| Login (SDDM) | `/usr/share/sddm/themes/sddm-astronaut-theme/Themes/dotfiles.conf` + `Backgrounds/dotfiles/` | user-owned slots written by `dots-login-sync`; shown at next login |
| Wallpaper | `~/.config/current-wallpaper` | first file in `wallpapers/<id>/` unless the current one already belongs to the theme |

Selected id: `~/.local/state/dotfiles/theme`.

## Add a theme

1. Copy `themes/.config/themes/themes/tokyo-night.conf` to `<id>.conf` and set `THEME_NAME`, `THEME_TYPE` (`dark`/`light`), `NVIM_THEME`, and the colours.
2. Put one or more wallpapers in `wallpapers/<id>/`.
3. `./update.sh --local --configs-only`, then `Mod+t`.

Templates are in `themes/.config/themes/templates/`; edit one when *every* theme should render a new setting. Placeholders: `{{BG}} {{BG_HEX}} {{BG_ALT}} {{FG}} {{FG_DIM}} {{PRIMARY}} {{SECONDARY}} {{ACCENT}} {{RED}} {{GREEN}} {{YELLOW}} {{BLUE}} {{MAGENTA}} {{CYAN}} {{WHITE}} {{BLACK}} {{THEME_NAME}} {{THEME_TYPE}}`. `sddm.template` additionally gets `{{LOGIN_BACKGROUND}}` (the wallpaper copied into the theme).

## Lock and login screens

- **Lock** (`Mod+Escape`, suspend via `xss-lock`): `dots-lock` runs `i3lock-color` with a blurred screenshot, a clock inside a ring indicator and `user@host` below it, all in the active theme's colours. `./install.sh i3` builds it as `/usr/local/bin/i3lock-color`; without it, `dots-lock` falls back to the distro `i3lock` in the theme background colour.
- **Login**: `./install.sh login` installs SDDM and clones the astronaut theme (pinned to its last Qt5 release on Debian/Ubuntu, whose `sddm-greeter` is Qt5, and to its last pre-`QtQuick.Effects` release on Fedora/Arch) into `/usr/share/sddm/themes/`, points it at `Themes/dotfiles.conf`, makes that file and `Backgrounds/dotfiles/` user-owned, and enables `sddm.service` in place of GDM. From then on `dots-login-sync` (called by `dots-theme-set` and `dots-bg-set`) rewrites the login colours and copies the current wallpaper there, so the login screen always matches the desktop. Reboot once after installing.

## Wallpapers

```text
wallpapers/
├── tokyo-night/        # used when tokyo-night is active
├── nord/ …             # one directory per theme id
└── shared/             # offered with every theme (lofi-*, an.jpg)
```

`./install.sh wallpapers` copies the tree to `~/Pictures/wallpapers/` additively, so machine-local extras dropped there survive updates. `Mod+Shift+b` lists everything; `Mod+Ctrl+Space` cycles the current theme's set.

## Dark mode and browser

Everything is dark by default: GTK 3/4 (`gtk/` package: Adwaita-dark, Papirus-Dark icons), the desktop portal (`portals.conf` → gtk, which is how browsers learn the colour scheme under i3), and every Zen/Firefox profile (`dots-darkmode` writes a `user.js` forcing dark UI *and* dark web content). Re-run `dots-darkmode` after creating a new browser profile.

Browser: **Zen** (`Mod+z`), Firefox-based with built-in split view, compact mode and workspaces. `./install.sh zen` drops an enterprise policy into `/opt/zen/distribution/` that installs **Vimium** automatically: `f` to hint-click links, `o` to search/open, `J`/`K` tabs, `/` find, `gg`/`G`, `H`/`L` back/forward. For a heavier, fully vim-modal setup swap Vimium for Tridactyl in `install/zen-policies.json`.
