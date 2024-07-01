#!/bin/bash

# Source all the function scripts
source ./install_packages.sh
source ./install_asdf.sh
source ./install_zsh.sh
source ./install_oh_my_zsh.sh
source ./install_powerlevel10k.sh
source ./install_fzf.sh
source ./clone_dotfiles.sh
source ./stow_dotfiles.sh

# Execute functions
install() {
    echo "Starting setup..."

    install_packages
    install_asdf
    install_asdf_plugins
    install_eza
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_fzf
    clone_dotfiles
    stow_dotfiles

    echo "Setup complete. Please restart your terminal or log out and back in for changes to take effect."
}

install

