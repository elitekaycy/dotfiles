#!/usr/bin/env bash
# Render and optionally apply one repository theme.

set -Eeuo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
THEMES_DIR="$CONFIG_HOME/themes"
THEMES_CONF_DIR="$THEMES_DIR/themes"
TEMPLATES_DIR="$THEMES_DIR/templates"
CURRENT_THEME_FILE="$STATE_DIR/theme"
RELOAD_APPS=true

C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_NONE='\033[0m'

log_info() { echo -e "${C_BLUE}[INFO]${C_NONE} $1"; }
log_success() { echo -e "${C_GREEN}[OK]${C_NONE} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_NONE} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_NONE} $1"; }

if [[ "${1:-}" == "--no-reload" ]]; then
    RELOAD_APPS=false
    shift
fi

THEME_ID="${1:-}"
if [[ -z "$THEME_ID" ]]; then
    echo "Usage: apply-theme.sh [--no-reload] <theme-name>"
    echo "Available themes:"
    for theme in "$THEMES_CONF_DIR"/*.conf; do
        [[ -f "$theme" ]] && basename "$theme" .conf
    done
    exit 1
fi

THEME_FILE="$THEMES_CONF_DIR/$THEME_ID.conf"
if [[ ! -f "$THEME_FILE" ]]; then
    log_error "Theme not found: $THEME_ID"
    exit 1
fi

# shellcheck disable=SC1090
source "$THEME_FILE"
: "${THEME_NAME:?Theme must define THEME_NAME}"
: "${THEME_TYPE:?Theme must define THEME_TYPE}"
: "${NVIM_THEME:?Theme must define NVIM_THEME}"

prepare_generated_output() {
    local output="$1"
    local link_target=""
    local themes_real=""
    local repository_root=""

    if [[ -L "$output" ]]; then
        link_target="$(readlink -f "$output" 2>/dev/null || true)"
        themes_real="$(readlink -f "$THEMES_DIR" 2>/dev/null || true)"
        repository_root="${themes_real%/themes/.config/themes}"

        # Migrate links created by older revisions. Foreign user-managed links
        # are deliberately left in place and receive the rendered content.
        if [[ -n "$repository_root" && "$link_target" == "$repository_root/"* ]]; then
            rm -- "$output"
        fi
    fi

    mkdir -p "$(dirname "$output")"
}

apply_template() {
    local template="$1"
    local output="$2"
    local content

    if [[ ! -f "$template" ]]; then
        log_error "Template not found: $template"
        return 1
    fi

    content="$(<"$template")"
    content="${content//\{\{THEME_NAME\}\}/$THEME_NAME}"
    content="${content//\{\{THEME_TYPE\}\}/$THEME_TYPE}"
    content="${content//\{\{BG\}\}/$BG}"
    content="${content//\{\{BG_HEX\}\}/${BG#\#}}"
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

    prepare_generated_output "$output"
    printf '%s\n' "$content" > "$output"
    log_success "Rendered: ${output#"$HOME"/}"
}

log_info "Rendering theme: $THEME_ID"
apply_template "$TEMPLATES_DIR/polybar.template" "$CONFIG_HOME/polybar/config.ini"
apply_template "$TEMPLATES_DIR/kitty.template" "$CONFIG_HOME/kitty/theme.conf"
apply_template "$TEMPLATES_DIR/dunst.template" "$CONFIG_HOME/dunst/dunstrc"
apply_template "$TEMPLATES_DIR/rofi.template" "$CONFIG_HOME/rofi/config.rasi"
apply_template "$TEMPLATES_DIR/i3.template" "$CONFIG_HOME/i3/theme.conf"
apply_template "$TEMPLATES_DIR/tmux.template" "$CONFIG_HOME/tmux/theme.conf"

mkdir -p "$HOME/.local/share/nvim" "$STATE_DIR"
printf '%s\n' "$NVIM_THEME" > "$HOME/.local/share/nvim/pvim_theme.txt"
printf '%s\n' "$THEME_ID" > "$CURRENT_THEME_FILE"

if [[ -n "${WALLPAPER:-}" ]]; then
    wallpaper_path="$HOME/Pictures/wallpapers/$WALLPAPER"
    if [[ -f "$wallpaper_path" ]]; then
        printf '%s\n' "$wallpaper_path" > "$CONFIG_HOME/current-wallpaper"
        wallpaper_script="$CONFIG_HOME/i3/wallpaper-setup.sh"
        if [[ "$RELOAD_APPS" == "true" && -n "${DISPLAY:-}" ]]; then
            if [[ -x "$wallpaper_script" ]]; then
                "$wallpaper_script" "$wallpaper_path" >/dev/null 2>&1 || true
            elif command -v feh >/dev/null; then
                feh --bg-fill "$wallpaper_path" >/dev/null 2>&1 || true
            fi
        fi
    else
        log_warn "Wallpaper not found: $wallpaper_path"
    fi
fi

if [[ "$RELOAD_APPS" == "true" && -n "${DISPLAY:-}" ]]; then
    if [[ -x "$CONFIG_HOME/polybar/launch.sh" ]]; then
        "$CONFIG_HOME/polybar/launch.sh" >/dev/null 2>&1 &
    fi

    if command -v kitty >/dev/null; then
        for sock in /tmp/mykitty*; do
            [[ -S "$sock" ]] || continue
            kitty @ --to "unix:$sock" set-colors -a -c "$CONFIG_HOME/kitty/theme.conf" >/dev/null 2>&1 || true
        done
    fi

    if command -v dunstctl >/dev/null; then
        pkill dunst 2>/dev/null || true
        dunst >/dev/null 2>&1 &
    fi

    command -v i3-msg >/dev/null && i3-msg reload >/dev/null 2>&1 || true
    if command -v tmux >/dev/null && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true
    fi
    command -v notify-send >/dev/null && notify-send "Theme Switcher" "Applied theme: $THEME_NAME" -i preferences-desktop-theme || true
fi

log_success "Theme '$THEME_NAME' applied"
