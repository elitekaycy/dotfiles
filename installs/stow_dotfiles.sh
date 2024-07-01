#!/bin/bash

stow_dotfiles() {
    cd "$DOTFILES_DIR" || exit
    # Stow all directories except installs/
    for dir in */; do
        if [ "$dir" != "installs/" ]; then
            stow "${dir%/}"
        fi
    done
}

