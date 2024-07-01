#!/bin/bash

install_powerlevel10k() {
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo "Powerlevel10k is already installed."
    else
        echo "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    fi
}

