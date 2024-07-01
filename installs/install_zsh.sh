#!/bin/bash

install_zsh() {
    if ! command -v zsh > /dev/null; then
        echo "Installing Zsh..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y zsh
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install zsh
        else
            echo "Unsupported OS. Please install Zsh manually."
            exit 1
        fi
    else
        echo "Zsh is already installed."
    fi
}

change_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Changing the default shell to zsh..."
        chsh -s $(which zsh)
    fi
}

