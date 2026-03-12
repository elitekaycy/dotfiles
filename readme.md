# Dotfiles

Minimal, high-productivity dotfiles for i3 + kitty + tmux + zsh + neovim on Linux.

![dotfiles](./docs/dotfiles.png)

## Quick Install

```bash
git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Zero manual steps. This handles everything:
- System packages (i3, kitty, tmux, zsh, docker, chrome, etc.)
- Dev tools via [mise](https://mise.jdx.dev) (node, java, python, bat, fzf, ripgrep, etc.)
- JetBrains Mono Nerd Font
- Symlinks all configs via stow
- Applies default Tokyo Night theme
- Sets zsh as default shell

**Supported distros:** Debian/Ubuntu, Fedora, Arch Linux

## Update Across Machines

After pushing changes (new tools, config updates, nvim plugins, etc.), run on any machine:

```bash
cd ~/dotfiles
./update.sh
```

This will pull latest changes, re-stow all configs, sync mise tools, update submodules (pvim, etc.), and install any new tmux plugins.

## Selective Install

```bash
./install.sh core       # git, stow, curl, build-essential
./install.sh i3         # i3wm, polybar, rofi, picom, dunst, feh, flameshot
./install.sh terminal   # kitty, tmux, zsh
./install.sh zsh        # oh-my-zsh, mise, atuin
./install.sh devtools   # all CLI tools via mise
./install.sh languages  # node, java, python, maven, gradle, pnpm via mise
./install.sh docker     # docker engine + compose
./install.sh chrome     # google chrome
./install.sh fonts      # JetBrains Mono Nerd Font
./install.sh rust       # rust toolchain
./install.sh stow       # symlink dotfiles only
./install.sh pvim       # neovim IDE config
./install.sh slack      # slack as web app
./install.sh media      # ncspot, ani-cli, lobster
./install.sh wallpapers # copy wallpapers
./install.sh themes     # apply default theme
```

## What's Included

### Configs

| Config | Description |
|--------|-------------|
| **i3** | Tiling WM with gaps, Tokyo Night theme, vim-style navigation |
| **polybar** | Status bar with clickable WiFi/Bluetooth/Power menus |
| **kitty** | GPU-accelerated terminal with remote control |
| **tmux** | Multiplexer with vim bindings, resurrect + continuum |
| **zsh** | Shell with znap, pure prompt, autosuggestions, syntax highlighting |
| **rofi** | App launcher, theme picker, wallpaper picker |
| **pvim** | Neovim IDE with LSP, treesitter, lazy.nvim, Java/TS support |
| **dunst** | Notification daemon |
| **picom** | Compositor for transparency and rounded corners |
| **git** | Gitconfig with delta diffs, aliases, auto-rebase |
| **mise** | Version manager config for all dev tools |

### Tools (managed by mise)

All dev tools are defined in a single config (`mise/.config/mise/config.toml`) and installed automatically.

| Category | Tools |
|----------|-------|
| **Languages** | Node.js 22/23, Java 17/21, Python 3.12 |
| **Build** | Maven 3.9, Gradle 8, pnpm |
| **CLI** | bat, btop, delta, eza, fd, fzf, gh, jq, ripgrep |
| **TUI** | lazygit, lazydocker, neovim |

### System Packages (via apt)

| Category | Packages |
|----------|----------|
| **WM** | i3, polybar, rofi, picom, dunst, feh, flameshot |
| **Terminal** | kitty, tmux, zsh |
| **System** | docker, chrome, i3lock, xss-lock, greenclip |
| **Media** | playerctl, pavucontrol, brightnessctl |

---

## Keybindings

### i3 Window Manager

#### Basics
| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (kitty) |
| `Mod+d` | Rofi launcher |
| `Mod+p` | dmenu |
| `Mod+b` | Firefox |
| `Mod+z` | Zen browser |
| `Mod+Shift+q` | Kill focused window |
| `Mod+Shift+r` | Restart/reload i3 |

#### Navigation (Vim-style)
| Key | Action |
|-----|--------|
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window left/down/up/right |
| `Mod+1-0` | Switch to workspace 1-10 |
| `Mod+Shift+1-0` | Move window to workspace 1-10 |

#### Layouts
| Key | Action |
|-----|--------|
| `Mod+a` | Split vertically |
| `Mod+-` | Split horizontally |
| `Mod+f` | Fullscreen |
| `Mod+s/w/e` | Stacking / Tabbed / Toggle split |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+c` | Move to center |

#### Screenshots (flameshot)
| Key | Action |
|-----|--------|
| `Mod+Shift+s` | Screenshot area |
| `Mod+Shift+f` | Screenshot fullscreen |
| `Mod+Shift+c` | Screenshot to clipboard |

#### System
| Key | Action |
|-----|--------|
| `Mod+t` | Theme switcher (rofi) |
| `Mod+Shift+b` | Wallpaper picker (rofi) |
| `Mod+v` | Clipboard history (rofi) |
| `Mod+Escape` | Lock screen |

#### Media
| Key | Action |
|-----|--------|
| `Mod+m` | Spotify TUI (ncspot) |
| `Mod+Shift+a` | Anime (ani-cli) |
| `Mod+Shift+v` | Movies/TV (lobster) |

#### Polybar (click controls)
| Module | Action |
|--------|--------|
| WiFi | Rofi network menu |
| Bluetooth | Rofi bluetooth menu |
| Volume | Right-click: pavucontrol |
| Power | Rofi power menu (lock/logout/suspend/hibernate/reboot/shutdown) |

---

### tmux

Prefix: `Ctrl+a`

| Key | Action |
|-----|--------|
| `Prefix + =` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Ctrl+h/j/k/l` | Navigate panes (works across neovim) |
| `Alt+H/L` | Previous/next window |
| `Prefix + [` | Copy mode (vim-style) |

**Aliases:** `tn <name>` (new), `ta <name>` (attach), `tl` (list), `tk <name>` (kill)

**Session persistence:** tmux-resurrect + tmux-continuum auto-saves every 10 min and restores on start.

---

### zsh

- Auto tmux attach/create on terminal open
- `Ctrl+r` - Search history (atuin)
- `Ctrl+t` - fzf file picker
- `Alt+c` - fzf cd to directory
- `z <dir>` - Smart directory jump

---

### Neovim (pvim)

Leader: `Space` | Seamless tmux integration via `Ctrl+h/j/k/l`

---

## Theme Switcher

`Mod+t` opens the theme picker. Changes apply to polybar, kitty, rofi, and dunst simultaneously. Wallpaper auto-matches the theme.

`Mod+Shift+b` to manually pick a wallpaper.

| Theme | Type |
|-------|------|
| Tokyo Night | Dark (default) |
| Tokyo Night Light | Light |
| Catppuccin Mocha | Dark |
| Catppuccin Latte | Light |
| Gruvbox Dark | Dark |
| Gruvbox Light | Light |
| Nord | Dark |
| Nord Light | Light |
| Dracula | Dark |

---

## Structure

```
dotfiles/
├── install.sh              # Main installer
├── install/                # Modular install scripts
│   ├── core.sh, i3.sh, terminal.sh, docker.sh, chrome.sh
│   ├── devtools.sh, languages.sh, neovim.sh (all use mise)
│   ├── zsh.sh, fonts.sh, rust.sh, greenclip.sh, slack.sh, media.sh
│   ├── setup.sh            # Stow, themes, tmux, pvim setup
│   └── utils.sh            # Shared helpers
├── mise/.config/mise/      # Tool versions (stowed to ~/.config/mise/)
├── i3/.config/i3/          # i3 config + scripts
├── polybar/.config/polybar/ # Polybar config + rofi menus
├── kitty/.config/kitty/    # Kitty terminal config
├── tmux/.tmux.conf         # Tmux config
├── zsh/.zshrc              # Zsh config
├── pvim/.config/pvim/      # Neovim IDE (submodule)
├── rofi/.config/rofi/      # Rofi launcher theme
├── dunst/.config/dunst/    # Notification config
├── picom/.config/picom/    # Compositor config
├── themes/.config/themes/  # Theme templates + scripts
├── git/.gitconfig          # Git config with delta
└── wallpapers/             # Anime/lofi wallpapers
```
