#!/usr/bin/env bash
#
# Theme Switcher - Apply theme across all configs
# Usage: apply-theme.sh <theme-name>
#

set -e

THEMES_DIR="$HOME/.config/themes"
THEMES_CONF_DIR="$THEMES_DIR/themes"
TEMPLATES_DIR="$THEMES_DIR/templates"
CURRENT_THEME_FILE="$THEMES_DIR/current"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if theme name provided
if [[ -z "$1" ]]; then
    echo "Usage: apply-theme.sh <theme-name>"
    echo "Available themes:"
    for theme in "$THEMES_CONF_DIR"/*.conf; do
        basename "$theme" .conf
    done
    exit 1
fi

THEME_ID="$1"
THEME_FILE="$THEMES_CONF_DIR/$THEME_ID.conf"

# Check if theme exists
if [[ ! -f "$THEME_FILE" ]]; then
    log_error "Theme not found: $THEME_ID"
    echo "Available themes:"
    for theme in "$THEMES_CONF_DIR"/*.conf; do
        basename "$theme" .conf
    done
    exit 1
fi

log_info "Applying theme: $THEME_ID"

# Source the theme file to get all color variables
source "$THEME_FILE"

# Function to replace placeholders in a template
apply_template() {
    local template="$1"
    local output="$2"

    if [[ ! -f "$template" ]]; then
        log_warn "Template not found: $template"
        return
    fi

    local content
    content=$(cat "$template")

    # Replace all {{VAR}} placeholders
    content="${content//\{\{THEME_NAME\}\}/$THEME_NAME}"
    content="${content//\{\{THEME_TYPE\}\}/$THEME_TYPE}"
    content="${content//\{\{BG\}\}/$BG}"
    content="${content//\{\{BG_ALT\}\}/$BG_ALT}"
    content="${content//\{\{FG\}\}/$FG}"
    content="${content//\{\{FG_DIM\}\}/$FG_DIM}"
    content="${content//\{\{PRIMARY\}\}/$PRIMARY}"
    content="${content//\{\{SECONDARY\}\}/$SECONDARY}"
    content="${content//\{\{ACCENT\}\}/$ACCENT}"
    content="${content//\{\{RED\}\}/$RED}"
    content="${content//\{\{GREEN\}\}/$GREEN}"
    content="${content//\{\{YELLOW\}\}/$YELLOW}"
    content="${content//\{\{BLUE\}\}/$BLUE}"
    content="${content//\{\{MAGENTA\}\}/$MAGENTA}"
    content="${content//\{\{CYAN\}\}/$CYAN}"
    content="${content//\{\{WHITE\}\}/$WHITE}"
    content="${content//\{\{BLACK\}\}/$BLACK}"

    # Create parent directory if needed
    mkdir -p "$(dirname "$output")"

    # Write to output file
    echo "$content" > "$output"
    log_success "Applied: $(basename "$output")"
}

# Apply all templates
log_info "Applying config templates..."

apply_template "$TEMPLATES_DIR/polybar.template" "$HOME/.config/polybar/config.ini"
apply_template "$TEMPLATES_DIR/kitty.template" "$HOME/.config/kitty/theme.conf"
apply_template "$TEMPLATES_DIR/dunst.template" "$HOME/.config/dunst/dunstrc"
apply_template "$TEMPLATES_DIR/rofi.template" "$HOME/.config/rofi/config.rasi"

# Update Neovim/pvim theme
log_info "Updating Neovim theme..."
NVIM_THEME_FILE="$HOME/.local/share/nvim/pvim_theme.txt"
mkdir -p "$(dirname "$NVIM_THEME_FILE")"
echo "$NVIM_THEME" > "$NVIM_THEME_FILE"
log_success "Neovim theme set to: $NVIM_THEME"

# Change wallpaper if specified and exists
if [[ -n "$WALLPAPER" ]]; then
    WALLPAPER_PATH="$HOME/Pictures/wallpapers/$WALLPAPER"
    if [[ -f "$WALLPAPER_PATH" ]]; then
        log_info "Setting wallpaper: $WALLPAPER"
        feh --bg-fill "$WALLPAPER_PATH" 2>/dev/null || true
        log_success "Wallpaper applied"
    else
        log_warn "Wallpaper not found: $WALLPAPER_PATH"
    fi
fi

# Reload applications
log_info "Reloading applications..."

# Reload polybar
if pgrep -x polybar > /dev/null; then
    pkill -x polybar
    sleep 0.5
fi
~/.config/polybar/launch.sh &>/dev/null &
log_success "Polybar reloaded"

# Reload kitty (if running with remote control)
if command -v kitty &> /dev/null && [[ -S /tmp/mykitty ]]; then
    kitty @ --to unix:/tmp/mykitty set-colors -a -c "$HOME/.config/kitty/theme.conf" 2>/dev/null || true
    log_success "Kitty colors updated"
fi

# Reload dunst
if command -v dunstctl &> /dev/null; then
    pkill dunst 2>/dev/null || true
    dunst &>/dev/null &
    log_success "Dunst reloaded"
fi

# Reload i3 (refreshes window borders)
if command -v i3-msg &> /dev/null; then
    i3-msg reload &>/dev/null || true
    log_success "i3 reloaded"
fi

# Save current theme ID
echo "$THEME_ID" > "$CURRENT_THEME_FILE"

# Send notification
if command -v notify-send &> /dev/null; then
    notify-send "Theme Switcher" "Applied theme: $THEME_NAME" -i preferences-desktop-theme
fi

echo ""
log_success "Theme '$THEME_NAME' applied successfully!"
echo ""
echo "Note: Restart Neovim to see colorscheme changes."
