# Dotfiles

Minimal, high-productivity dotfiles for i3 + kitty + tmux + zsh + neovim.

![eg](./docs/i3doc.png)

## Quick Install

```bash
git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This will:
- Install all dependencies (i3, kitty, tmux, zsh, neovim, etc.)
- Install JetBrains Mono Nerd Font
- Symlink all configs via stow
- Set zsh as default shell

**Supported distros:** Debian/Ubuntu, Fedora, Arch Linux

## Manual Install

If you prefer to install specific components:

```bash
./install.sh core       # git, stow, curl, etc.
./install.sh i3         # i3wm, i3blocks, rofi, dmenu, feh, flameshot, dunst, etc.
./install.sh terminal   # kitty, tmux, zsh
./install.sh devtools   # bat, fd, fzf, eza, ripgrep, btop
./install.sh fonts      # JetBrains Mono Nerd Font
./install.sh stow       # Symlink dotfiles only
./install.sh pvim       # Setup neovim (pvim config)
./install.sh slack      # Slack as web app (replaces desktop app)
./install.sh wallpapers # Copy wallpapers to ~/Pictures/wallpapers
./install.sh greenclip  # Clipboard manager
```

## What's Included

| Config | Description |
|--------|-------------|
| **i3** | Tiling WM with Tokyo Night theme, vim-style navigation |
| **kitty** | GPU-accelerated terminal |
| **tmux** | Terminal multiplexer with vim bindings, TPM plugins |
| **zsh** | Shell with znap, pure prompt, autosuggestions, syntax highlighting |
| **rofi** | App launcher with Tokyo Night theme |
| **pvim** | Neovim config with LSP, treesitter, lazy.nvim |
| **dunst** | Notification daemon with Tokyo Night theme |
| **picom** | Compositor for transparency and no screen tearing |

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

#### Window Navigation (Vim-style)
| Key | Action |
|-----|--------|
| `Mod+h` | Focus left |
| `Mod+j` | Focus down |
| `Mod+k` | Focus up |
| `Mod+l` | Focus right |
| `Mod+Left/Down/Up/Right` | Focus (arrow keys) |

#### Move Windows
| Key | Action |
|-----|--------|
| `Mod+Shift+h` | Move window left |
| `Mod+Shift+j` | Move window down |
| `Mod+Shift+k` | Move window up |
| `Mod+Shift+l` | Move window right |
| `Mod+Shift+Left/Down/Up/Right` | Move (arrow keys) |

#### Layouts
| Key | Action |
|-----|--------|
| `Mod+a` | Split vertically |
| `Mod+-` | Split horizontally |
| `Mod+=` | Toggle split |
| `Mod+s` | Stacking layout |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |
| `Mod+f` | Fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Space` | Toggle focus (tiling/floating) |
| `Mod+c` | Move to center |

#### Workspaces
| Key | Action |
|-----|--------|
| `Mod+1-0` | Switch to workspace 1-10 |
| `Mod+Shift+1-0` | Move window to workspace 1-10 |

#### Screenshots (flameshot)
| Key | Action |
|-----|--------|
| `Mod+Shift+s` | Screenshot area (select) |
| `Mod+Shift+f` | Screenshot fullscreen |
| `Mod+Shift+c` | Screenshot to clipboard |

#### System
| Key | Action |
|-----|--------|
| `Mod+Escape` | Lock screen |
| `Mod+v` | Clipboard history (rofi) |
| `XF86AudioPlay` | Play/pause media |
| `XF86AudioNext/Prev` | Next/previous track |

---

### tmux

#### Prefix
The prefix key is `Ctrl+a` (not the default `Ctrl+b`).

#### Sessions
| Key | Action |
|-----|--------|
| `tmux` | Start new session (or attach to existing) |
| `tmux ls` | List sessions |
| `Prefix + s` | Session picker |
| `Prefix + $` | Rename session |
| `Prefix + d` | Detach from session |

**Shell aliases:**
| Alias | Action |
|-------|--------|
| `tn <name>` | New session with name |
| `ta <name>` | Attach to session |
| `tl` | List sessions |
| `tk <name>` | Kill session |

#### Windows (tabs)
| Key | Action |
|-----|--------|
| `Ctrl+a` | New window (in normal mode) |
| `Alt+H` | Previous window |
| `Alt+L` | Next window |
| `Prefix + w` | Window/session tree |
| `Prefix + ,` | Rename window |
| `Prefix + &` | Close window |
| `Prefix + 0-9` | Switch to window number |

#### Panes (splits)
| Key | Action |
|-----|--------|
| `Prefix + =` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + x` | Close pane |
| `Prefix + z` | Zoom pane (fullscreen toggle) |
| `Prefix + {` | Swap pane left |
| `Prefix + }` | Swap pane right |
| `Prefix + Space` | Cycle pane layouts |

#### Pane Navigation (vim-tmux-navigator)
| Key | Action |
|-----|--------|
| `Ctrl+h` | Move to pane left |
| `Ctrl+j` | Move to pane down |
| `Ctrl+k` | Move to pane up |
| `Ctrl+l` | Move to pane right |

*Works seamlessly between tmux panes and neovim splits!*

#### Copy Mode (vim-style)
| Key | Action |
|-----|--------|
| `Prefix + [` | Enter copy mode |
| `v` | Start selection |
| `Ctrl+v` | Rectangle selection |
| `y` | Copy and exit |
| `q` | Exit copy mode |

---

### zsh

#### Auto tmux
- Opens a new terminal → attaches to existing tmux session or creates "main"
- Multiple sessions → fzf picker to choose

#### Navigation
| Key | Action |
|-----|--------|
| `Ctrl+r` | Search command history (atuin) |
| `Ctrl+t` | fzf file picker |
| `Alt+c` | fzf cd to directory |
| `Tab` | Autocomplete |
| `→` (Right arrow) | Accept autosuggestion |

---

### Neovim (pvim)

Uses vim-tmux-navigator for seamless pane switching:

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Navigate splits (works across tmux too) |
| `Space` | Leader key |

---

## Theme

**Tokyo Night** color scheme across all configs:
- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Blue (accent): `#7aa2f7`
- Cyan: `#7dcfff`
- Green: `#9ece6a`
- Magenta: `#bb9af7`
- Red: `#f7768e`

---

## Dependencies

Auto-installed by `install.sh`:

- **Window Manager:** i3, i3blocks, rofi, dmenu, feh, picom, dunst
- **Terminal:** kitty, tmux, zsh
- **Editor:** neovim
- **Tools:** bat, fd, fzf, eza, ripgrep, btop, flameshot, redshift, playerctl, greenclip
- **Security:** i3lock, xss-lock
- **Fonts:** JetBrains Mono Nerd Font

## Submodules

```bash
git submodule update --init --recursive
```
