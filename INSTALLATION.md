# Installation Guide

This document provides a list of dependencies that need to be installed for these dotfiles to function correctly.

## Core Dependencies

These are the essential packages required for the dotfiles to work.

*   **stow**: Used to manage the dotfiles by creating symbolic links.
*   **git**: Required for cloning the repository and managing submodules.
*   **zsh**: The Z shell, which is the primary shell environment.
*   **Oh My Zsh**: A framework for managing your zsh configuration.
*   **tmux**: A terminal multiplexer.
*   **Neovim**: A modern, highly extensible text editor.
*   **i3**: A tiling window manager.
*   **i3status**: A status bar for i3.
*   **kitty**: A GPU-based terminal emulator.
*   **rofi**: A window switcher, application launcher, and dmenu replacement.
*   **dmenu**: A dynamic menu for X.
*   **feh**: A light-weight image viewer, used here to set the wallpaper.
*   **nm-applet**: A network manager applet for the system tray.
*   **volumeicon**: A volume control icon for the system tray.
*   **blueman-applet**: A Bluetooth manager applet for the system tray.
*   **xinput**: A utility to configure and test X11 input devices.
*   **acpi**: A tool to display information about ACPI devices, used here for battery status.
*   **amixer**: A command-line mixer for ALSA sound-card driver.
*   **sensors**: A tool to show readings from hardware sensors.
*   **bat**: A cat(1) clone with wings, used for syntax highlighting.
*   **fd**: A simple, fast and user-friendly alternative to `find`.
*   **fzf**: A command-line fuzzy finder.
*   **eza**: A modern replacement for `ls`.
*   **asdf**: A CLI tool that can manage multiple language runtime versions on a per-project basis.
*   **atuin**: A tool that replaces your existing shell history with a SQLite database.

## Fonts

The following fonts are used in the configurations:

*   **JetBrains Mono Nerd Font**: Used in the i3 and kitty configurations.

## Installation Commands

Here are the commands to install the dependencies on a Debian-based system (e.g., Ubuntu):

```bash
sudo apt-get update
sudo apt-get install -y \
    stow \
    git \
    zsh \
    tmux \
    neovim \
    i3 \
    i3status \
    kitty \
    rofi \
    dmenu \
    feh \
    network-manager-gnome \
    volumeicon-alsa \
    blueman \
    xinput \
    acpi \
    alsa-utils \
    lm-sensors \
    bat \
    fd-find \
    fzf \
    eza
```

### Installing Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Installing asdf

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
```

### Installing atuin

```bash
bash <(curl https://raw.githubusercontent.com/ellie/atuin/main/install.sh)
```

## Notes

*   The `bat` binary may be named `batcat` on Debian-based systems. The `.zshrc` file already has an alias for this.
*   The `fd` binary may be named `fdfind` on Debian-based systems. The `.zshrc` file already has an alias for this.
*   After installing `asdf`, you will need to add the necessary plugins for the languages you want to manage. For example, to add the Java plugin, you would run `asdf plugin-add java`.
*   The Neovim configurations are based on LazyVim and pvim, which have their own set of dependencies. You will need to run `:Lazy` in Neovim to install the plugins.

```