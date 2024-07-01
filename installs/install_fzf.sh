#!/bin/bash

install_fzf() {
    if command -v fzf > /dev/null; then
        echo "fzf is already installed."
    else
        echo "Installing fzf..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y fzf
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install fzf
        else
            echo "Unsupported OS. Please install fzf manually."
            exit 1
        fi
    fi
}

