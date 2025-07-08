# My Dotfiles

These are my personal dotfiles for various applications. I use `stow` to manage them.

## Managed Applications

This repository contains configurations for the following applications:

*   **bash**: `.bashrc`
*   **i3**: i3 window manager
*   **i3status**: i3status bar
*   **idea**: `.ideavimrc` for JetBrains IDEs
*   **kitty**: kitty terminal emulator
*   **nvim**: Neovim (LazyVim)
*   **pvim**: A separate Neovim configuration
*   **tmux**: tmux terminal multiplexer
*   **vim**: `.vimrc`
*   **zsh**: `.zshrc`

## Installation

1.  **Clone the repository:**

    ```bash
    git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/.dotfiles
    ```

2.  **Install the dotfiles using `stow`:**

    Navigate to the cloned directory and use `stow` to create symbolic links for the desired application configurations. For example, to install the `zsh` and `tmux` configurations, you would run:

    ```bash
    cd ~/.dotfiles
    stow zsh
    stow tmux
    ```

    To install all configurations, you can run the following command:

    ```bash
    cd ~/.dotfiles
    stow */
    ```

## Submodules

This repository uses submodules for some of the configurations. To make sure they are cloned correctly, use the `--recurse-submodules` flag when cloning the repository.

If you have already cloned the repository without the submodules, you can initialize them with the following command:

```bash
git submodule update --init --recursive
```

<!--![eg](./docs/i3doc.png)-->
![eg](./docs/i3doc.png)

