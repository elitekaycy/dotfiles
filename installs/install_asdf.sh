#!/bin/bash

install_asdf() {
    ASDF_DIR="$HOME/.asdf"
    if [ -d "$ASDF_DIR" ]; then
        echo "asdf is already installed."
    else
        echo "Installing asdf..."
        git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v0.12.0
    fi
}

install_asdf_plugins() {
    . $HOME/.asdf/asdf.sh
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true

    asdf install nodejs latest

    asdf global nodejs latest
}

install_eza() {
    . $HOME/.asdf/asdf.sh
    asdf plugin add eza https://github.com/tmccombs/asdf-eza.git || true
    asdf install eza latest
    asdf global eza latest
}


