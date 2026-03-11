# Custom Theme Switcher Plan

## Overview

A unified theme system that switches colors across all configs via rofi menu (`Mod+t`).

## Architecture

```
~/.config/themes/
├── themes/
│   ├── tokyo-night.conf      # Theme color definitions
│   ├── catppuccin-mocha.conf
│   ├── gruvbox-dark.conf
│   ├── nord.conf
│   └── dracula.conf
├── templates/
│   ├── polybar.template      # Config templates with {{placeholders}}
│   ├── kitty.template
│   ├── dunst.template
│   ├── rofi.template
│   └── i3.template
├── apply-theme.sh            # Main script that applies theme
├── rofi-theme-picker.sh      # Rofi menu script
└── current                   # Symlink or file tracking current theme
```

## Theme Definition Format (tokyo-night.conf)

```bash
# Tokyo Night Theme
THEME_NAME="Tokyo Night"
WALLPAPER="tokyo-night.jpg"

# Base colors
BG="#1a1b26"
BG_ALT="#24283b"
FG="#c0caf5"
FG_DIM="#565f89"

# Accent colors
PRIMARY="#7aa2f7"      # Blue
SECONDARY="#bb9af7"    # Magenta
ACCENT="#7dcfff"       # Cyan

# Semantic colors
RED="#f7768e"
GREEN="#9ece6a"
YELLOW="#e0af68"
BLUE="#7aa2f7"
MAGENTA="#bb9af7"
CYAN="#7dcfff"
WHITE="#a9b1d6"
BLACK="#15161e"

# Neovim colorscheme name
NVIM_THEME="tokyonight-night"
```

## Template Example (polybar.template)

```ini
[colors]
background = {{BG}}
background-alt = {{BG_ALT}}
foreground = {{FG}}
primary = {{PRIMARY}}
...
```

## Apply Script Flow

1. Source the theme file (get all color variables)
2. For each template:
   - Read template
   - Replace `{{VAR}}` with actual values
   - Write to actual config location
3. Reload apps:
   - `polybar-msg cmd restart` or relaunch
   - `kitty @ set-colors` (live reload)
   - Signal nvim to change colorscheme
   - `dunstctl reload`
   - `i3-msg reload`
4. Save current theme name

## Rofi Picker

- Lists all `.conf` files in themes/
- Shows theme name + preview colors (if possible)
- On select → runs `apply-theme.sh <theme-name>`
- Notification confirms theme applied

## Keybinding

```
bindsym $mod+t exec ~/.config/themes/rofi-theme-picker.sh
```

## Live Reload Support

| App | Method |
|-----|--------|
| Polybar | Kill & relaunch |
| Kitty | `kitty @ set-colors -a -c <file>` |
| Neovim | Write to file, nvim reads on focus |
| Dunst | `dunstctl reload` |
| i3 | `i3-msg reload` |
| Rofi | Just uses new config next time |

## Initial Themes to Include

1. **Tokyo Night** (current default)
2. **Catppuccin Mocha** (popular, similar vibe)
3. **Gruvbox Dark** (warm, retro)
4. **Nord** (cool, minimal)
5. **Dracula** (purple, high contrast)

## Files to Modify

- `i3/config` - Add keybind, use color variables
- `polybar/config.ini` - Already has colors section
- `kitty/kitty.conf` - Color definitions
- `dunst/dunstrc` - Urgency colors
- `rofi/` - Theme file (if exists)
- `pvim/` - Set colorscheme variable

## Decisions

- ✅ Wallpaper changes with theme
- ✅ Include light themes (Tokyo Night Light, Catppuccin Latte, Gruvbox Light, Nord Light)

## Implementation Order

1. Create directory structure
2. Create theme definition files (dark + light)
3. Create config templates
4. Create apply-theme.sh script
5. Create rofi-theme-picker.sh
6. Add keybind to i3
7. Update install.sh
8. Test & commit
