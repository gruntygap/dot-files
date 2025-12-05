#!/usr/bin/env bash

# Check if stow is installed
if command -v stow >/dev/null 2>&1; then
    echo "Stow is already installed."
else
    echo "Stow is not installed. Installing now..."

    # Detect OS and install accordingly
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y stow
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y stow
        else
            echo "Unsupported Linux package manager. Please install stow manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install stow
        else
            echo "Homebrew not found. Please install Homebrew or stow manually."
            exit 1
        fi
    else
        echo "Unsupported OS. Please install stow manually."
        exit 1
    fi

    echo "Stow installation complete."
fi
