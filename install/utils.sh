#!/usr/bin/env bash
# Shared utilities for install scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
has() { command -v "$1" &>/dev/null; }

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop|linuxmint) echo "debian" ;;
            fedora) echo "fedora" ;;
            arch|manjaro|endeavouros) echo "arch" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

# Package manager helpers
pkg_install() {
    case "$OS" in
        debian) sudo apt-get install -y "$@" ;;
        fedora) sudo dnf install -y "$@" ;;
        arch) sudo pacman -S --noconfirm "$@" ;;
    esac
}

pkg_update() {
    case "$OS" in
        debian) sudo apt-get update ;;
        fedora) sudo dnf check-update || true ;;
        arch) sudo pacman -Sy ;;
    esac
}

# Export OS variable
OS=$(detect_os)
