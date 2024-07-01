#!/bin/bash

install_package() {
    PACKAGE=$1
    if command -v $PACKAGE > /dev/null; then
        echo "$PACKAGE is already installed."
    else
        echo "$PACKAGE is not installed. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y $PACKAGE
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install $PACKAGE
        else
            echo "Unsupported OS. Please install $PACKAGE manually."
            exit 1
        fi
    fi
}

install_packages() {
    install_package git
    install_package curl
    install_package stow
    install_package zsh
    install_package bat
}

