#!/bin/bash

clone_dotfiles() {
    DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
    DOTFILES_DIR="$HOME/dotfiles"
    if [ -d "$DOTFILES_DIR" ]; then
        echo "Dotfiles repository already cloned."
    else
        echo "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
}

