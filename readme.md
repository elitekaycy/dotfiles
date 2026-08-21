# elitekaycy/dotfiles

[![Verify dotfiles](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml/badge.svg)](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml)

My i3 workstation: i3 + Polybar + Rofi + Kitty + tmux + Zsh + Neovim (pvim), themed from one source and driven by a small set of `dots-*` commands. Built for me, kept lean.

![Desktop running these dotfiles](./docs/dotfiles.png)

## How it fits together

```text
themes/<id>.conf  ──►  dots-theme-set  ──►  polybar · kitty · dunst · rofi · i3 · tmux · pvim · wallpaper
                            ▲
   Mod+t / Mod+Ctrl+Shift+Space ── dots-theme-menu (rofi)
   Mod+Ctrl+t ──────────────────── dots-theme-next
   Mod+Alt+Space ───────────────── dots-menu (hub: apps, theme, wallpaper, sessions, wifi, bluetooth, …)
```

- **One theme source** (`themes/.config/themes/themes/<id>.conf`) defines ~20 colours. `dots-theme-set` renders every app template from it and reloads the desktop. Nothing is hardcoded per app.
- **Per-theme wallpapers** live in `wallpapers/<theme-id>/`; `wallpapers/shared/` works with any theme. Switching theme switches wallpaper; `Mod+Ctrl+Space` cycles within the theme.
- **Every picker is Rofi** and every action is a `dots-*` command, so i3, Polybar and the shell all call the same thing.
- **Stow deploys** each package without folding directories; generated files are user state, never committed.

## Install

```bash
git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # full workstation (Ubuntu/Debian, Fedora, Arch)
```

Conflicting unmanaged files are moved (never deleted) to `~/.local/state/dotfiles/backups/<timestamp>/`. Log out after the first full install.

| Component | What it does |
| --- | --- |
| `./install.sh stow [--dry-run]` | Reconcile config symlinks only |
| `./install.sh setup` | Links, wallpapers, theme, TPM plugins, pvim |
| `./install.sh themes` | Render the saved theme (Tokyo Night on first use) |
| `./install.sh wallpapers` | Copy `wallpapers/` into `~/Pictures/wallpapers/` |
| `./install.sh core` / `i3` / `terminal` / `fonts` / `zsh` | System packages by area |
| `./install.sh devtools` / `languages` | Everything in the mise manifest |
| `./install.sh docker` / `chrome` / `rust` / `nvidia` / `greenclip` / `slack` / `media` | Optional extras |
| `./install.sh check` | Run the verification suite, change nothing |

## Update

```bash
./update.sh                          # fast-forward, verify, restow, re-render theme, mise + TPM
./update.sh --local                  # skip git; apply the current checkout
./update.sh --local --configs-only   # links + theme + wallpapers only, no tool sync
./update.sh --check                  # fetch + verify, deploy nothing
```

A dirty checkout is never reset, rebased or stashed; it is deployed as-is and the command exits `2`.

## Commands

All live in `bin/.local/bin/` and are on `PATH` as `~/.local/bin/dots-*`.

| Command | Does |
| --- | --- |
| `dots-menu` | Rofi hub: Apps · Theme · Wallpaper · Session · Keybindings · WiFi · Bluetooth · Screenshot · Clipboard · Lock · Power |
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
| `dots-lock` | i3lock in the theme background colour |
| `dots-power` | Lock · Logout · Suspend · Hibernate · Reboot · Shutdown |

## Themes

Available: `catppuccin-latte` `catppuccin-mocha` `dracula` `gruvbox-dark` `gruvbox-light` `nord` `nord-light` `tokyo-night` `tokyo-night-light`

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
| Lockscreen | — | `dots-lock` reads the theme background |
| Wallpaper | `~/.config/current-wallpaper` | first file in `wallpapers/<id>/` unless the current one already belongs to the theme |

Selected id: `~/.local/state/dotfiles/theme`.

### Add a theme

1. Copy `themes/.config/themes/themes/tokyo-night.conf` to `<id>.conf` and set `THEME_NAME`, `THEME_TYPE` (`dark`/`light`), `NVIM_THEME`, and the colours.
2. Put one or more wallpapers in `wallpapers/<id>/`.
3. `./update.sh --local --configs-only`, then `Mod+t`.

Templates are in `themes/.config/themes/templates/`; edit one when *every* theme should render a new setting. Placeholders: `{{BG}} {{BG_HEX}} {{BG_ALT}} {{FG}} {{FG_DIM}} {{PRIMARY}} {{SECONDARY}} {{ACCENT}} {{RED}} {{GREEN}} {{YELLOW}} {{BLUE}} {{MAGENTA}} {{CYAN}} {{WHITE}} {{BLACK}} {{THEME_NAME}} {{THEME_TYPE}}`.

## Wallpapers

```text
wallpapers/
├── tokyo-night/        # used when tokyo-night is active
├── nord/ …             # one directory per theme id
└── shared/             # offered with every theme (lofi-*, an.jpg)
```

`./install.sh wallpapers` copies the tree to `~/Pictures/wallpapers/` additively, so machine-local extras dropped there survive updates. `Mod+Shift+b` lists everything; `Mod+Ctrl+Space` cycles the current theme's set.

## Keybindings

`Mod` = Super. Shown live with `Mod+Shift+/` (`dots-keys`).

### Launchers and menus

| Key | Action |
| --- | --- |
| `Mod+Return` | Kitty |
| `Mod+d` | Rofi app launcher |
| `Mod+Alt+Space` | **Main menu hub** (`dots-menu`) |
| `Mod+v` | Clipboard history (greenclip) |
| `Mod+Shift+/` | Keybinding reference |
| `Mod+z` / `Mod+b` | Zen browser / Firefox |
| `Mod+m` | ncspot |
| `Mod+Shift+a` / `Mod+Shift+v` | ani-cli / lobster |
| `Mod+Shift+w` | tmux session `work` |
| `Mod+Shift+t` | tmux session `scalestash` |

### Theme and wallpaper

| Key | Action |
| --- | --- |
| `Mod+t` or `Mod+Ctrl+Shift+Space` | Theme picker |
| `Mod+Ctrl+t` | Next theme |
| `Mod+Shift+b` | Wallpaper picker |
| `Mod+Ctrl+Space` | Next wallpaper (current theme) |

### Windows and workspaces

| Key | Action |
| --- | --- |
| `Mod+h/j/k/l` or arrows | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` or `Mod+Shift+arrows` | Move window |
| `Mod+1…0` / `Mod+Shift+1…0` | Go to / move to workspace 1…10 |
| `Mod+a` / `Mod+-` | Split vertical / horizontal |
| `Mod+s` / `Mod+w` / `Mod+e` | Stacking / tabbed / toggle split |
| `Mod+=` | Toggle split layout |
| `Mod+f` | Fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Space` | Focus tiling ↔ floating |
| `Mod+c` | Centre floating window |
| `Mod+Shift+q` | Close window |
| `Mod+Shift+r` | Restart i3 |

### System

| Key | Action |
| --- | --- |
| `Mod+Escape` | Lock |
| `Mod+Shift+s` / `Mod+Shift+f` / `Mod+Shift+c` | Screenshot area / full / area→clipboard |
| `XF86 brightness / volume / media keys` | brightnessctl, pactl, playerctl |

Polybar: click WiFi / Bluetooth / power for their menus; right-click volume for `pavucontrol`.

### tmux (prefix `Ctrl+g`)

| Key | Action |
| --- | --- |
| `Ctrl+g p` then `n/r/l/u/d` | Split right/right/left/up/down in the current directory |
| `Ctrl+g t` then `n/h/l` | New window / previous / next |
| `Ctrl+h/j/k/l` | Move between panes and Neovim splits |
| `Alt+H` / `Alt+L` | Previous / next window |
| `Ctrl+g [` | Copy mode (vi keys; `v` select, `y` yank) |

Shell: `tn <name>` new, `ta <name>` attach, `tl` list, `tk <name>` kill.

## Repository layout

```text
.
├── install.sh / update.sh        # entry points
├── install/                      # package installers, Stow deployer (DOTFILES_PACKAGES), setup steps
├── scripts/verify.sh             # local + CI verification
├── tests/                        # temp-HOME integration tests
├── bin/.local/bin/dots-*         # all commands
├── themes/.config/themes/        # themes/<id>.conf + templates/<app>.template
├── wallpapers/<theme-id>/        # per-theme wallpapers, plus shared/
├── i3/  polybar/  kitty/  tmux/  picom/  zsh/  bash/  git/  mise/  broot/  vim/  idea/  nvim/
└── pvim/.config/pvim/            # Neovim config (git submodule)
```

Generated and untracked: `polybar/config.ini`, `kitty/theme.conf`, `dunst/dunstrc`, `rofi/config.rasi`, `i3/theme.conf`, `tmux/theme.conf`.

## Verify before committing

```bash
./scripts/verify.sh
```

Conventions and commit rules: [`CLAUDE.md`](./CLAUDE.md).

## Troubleshooting

- Theme looks half-applied → `dots-theme-set $(dots-theme-current)`; check `~/.config/<app>/theme.conf` exists.
- Wallpaper missing after a theme switch → `./install.sh wallpapers` (the theme directory in `~/Pictures/wallpapers/` is empty).
- A `dots-*` command is missing → `./install.sh stow`.
- Restore an overwritten file from `~/.local/state/dotfiles/backups/`.
- `./update.sh` exits `2` → local changes were preserved and upstream sync skipped; commit and rerun.

## License

[MIT](./LICENSE)
