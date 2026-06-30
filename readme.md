# elitekaycy/dotfiles

[![Verify dotfiles](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml/badge.svg)](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml)

Portable, conflict-aware Linux dotfiles for an i3, Kitty, tmux, Zsh, Neovim, Rofi, and Polybar workstation.

![Desktop running these dotfiles](./docs/dotfiles.png)

## What this repository does

- Installs workstation packages on Ubuntu/Debian, Fedora, and Arch-based systems.
- Manages language runtimes and CLI tools from one [mise](https://mise.jdx.dev/) manifest.
- Deploys configuration with GNU Stow without replacing whole config directories.
- Preserves conflicting files under `~/.local/state/dotfiles/backups/` before linking.
- Updates only by fast-forward; it never resets, rebases, or auto-stashes local work.
- Renders synchronized Polybar, Kitty, Dunst, Rofi, Neovim, and wallpaper themes.
- Verifies shell syntax, structured config, submodules, tmux, Neovim, fresh installs, and upgrades in CI.

The full installer is opinionated: it can install i3, NVIDIA drivers when detected, Docker, Chrome, Rust, fonts, and development tools. Review `install.sh` and use a selective component if you do not want the complete workstation.

## Requirements

- A supported Linux family: Ubuntu/Debian, Fedora, Arch/Manjaro/EndeavourOS
- `git` for cloning
- `sudo` access for system packages
- An internet connection for the first full install

Desktop behavior targets X11+i3. The config files can still be installed selectively on another desktop.

## Fresh installation

```bash
git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent. Existing unmanaged files that collide with a managed file are moved—not deleted—to a timestamped directory under:

```text
~/.local/state/dotfiles/backups/
```

Unrelated files inside directories such as `~/.config/nvim/` are left in place. Log out after the first full install so the shell, Docker group, and i3 session changes take effect.

### Preview or verify first

```bash
./install.sh stow --dry-run  # show Stow conflicts; change nothing
./install.sh check           # run the repository verification suite
./scripts/verify.sh          # same verifier used by GitHub Actions
```

### Selective install commands

| Command | Purpose |
| --- | --- |
| `./install.sh core` | Git, curl, wget, Stow, build tools, unzip, xclip |
| `./install.sh nvidia` | Install a driver only when an NVIDIA GPU is detected |
| `./install.sh i3` | i3, Rofi, Polybar, Picom, Dunst, Feh, Flameshot, and desktop utilities |
| `./install.sh terminal` | Kitty, tmux, and Zsh packages |
| `./install.sh zsh` | Oh My Zsh, mise, and Atuin |
| `./install.sh devtools` | Install every tool declared in the mise config |
| `./install.sh languages` | Node.js, Java, Python, Maven, Gradle, and pnpm |
| `./install.sh docker` | Docker Engine and Compose |
| `./install.sh chrome` | Google Chrome |
| `./install.sh fonts` | JetBrains Mono Nerd Font |
| `./install.sh greenclip` | Greenclip clipboard manager |
| `./install.sh rust` | Rust via rustup |
| `./install.sh stow` | Safely reconcile config links only |
| `./install.sh setup` | Config links, wallpapers, theme, TPM plugins, and pvim setup |
| `./install.sh pvim` | Run the pvim submodule installer |
| `./install.sh themes` | Render the saved theme, or Tokyo Night on first use |
| `./install.sh wallpapers` | Copy repository wallpapers into `~/Pictures/wallpapers/` |
| `./install.sh slack` | Create a Chrome-based Slack web app |
| `./install.sh media` | Install ncspot, ani-cli, and lobster |
| `./install.sh check` | Run all repository checks without changing the system |

Unknown component names fail instead of accidentally running the full installer.

## Safe updates

On a machine with a clean checkout:

```bash
cd ~/dotfiles
./update.sh
```

The default update:

1. acquires a lock so two updates cannot overlap;
2. fetches and fast-forwards the configured upstream;
3. updates the `pvim` submodule;
4. runs the same verification suite as CI;
5. reconciles Stow links and backs up real conflicts;
6. refreshes wallpapers and the selected theme;
7. runs `mise install` and updates TPM plugins; and
8. reloads i3/tmux when they are running.

It intentionally does not run `mise prune`, rewrite Git history, delete unmanaged files, or hide local changes in an automatic stash.

| Command | Behavior |
| --- | --- |
| `./update.sh` | Sync upstream, verify, deploy configs, and sync tools/plugins |
| `./update.sh --check` | Fetch and verify only; deploy nothing |
| `./update.sh --local` | Skip Git and deploy intentional edits in the current checkout |
| `./update.sh --configs-only` | Reconcile configs/themes/wallpapers; skip mise and TPM updates |
| `./update.sh --no-reload` | Update everything without reloading desktop applications |
| `./update.sh --local --configs-only --no-reload` | Apply local config edits with no network/tool/reload side effects |

If the checkout is dirty, the default command preserves it, skips remote synchronization, deploys the current local files, and exits with status `2` so automation can detect that upstream was not applied. Commit or stash the changes and rerun to receive remote updates.

## Themes

Press `Mod+t` to open the Rofi theme picker. A selection updates Polybar, Kitty, Dunst, Rofi, the pvim theme marker, and the matching wallpaper.

Apply a theme directly:

```bash
~/.config/themes/scripts/apply-theme.sh tokyo-night
~/.config/themes/scripts/apply-theme.sh --no-reload nord
```

Available theme IDs:

- `catppuccin-latte`
- `catppuccin-mocha`
- `dracula`
- `gruvbox-dark`
- `gruvbox-light`
- `nord`
- `nord-light`
- `tokyo-night`
- `tokyo-night-light`

The selected ID is stored at `~/.local/state/dotfiles/theme`. Rendered application files are user state and are deliberately not tracked by Git.

### Add a theme

1. Copy a file in `themes/.config/themes/themes/`, for example `tokyo-night.conf`.
2. Give it a unique lowercase filename; that filename is the CLI/Rofi theme ID.
3. Define `THEME_NAME`, `THEME_TYPE`, `WALLPAPER`, `NVIM_THEME`, and every color variable used by the templates.
4. Add the referenced wallpaper to `wallpapers/`.
5. Run `./update.sh --local --configs-only`, then select the theme with `Mod+t`.
6. Run `./scripts/verify.sh` before committing.

The templates live in `themes/.config/themes/templates/`. Change a template when every theme should render a new application setting.

## Wallpapers

Press `Mod+Shift+b` to open the Rofi wallpaper picker. It reads `.jpg`, `.jpeg`, `.png`, and `.webp` files from `~/Pictures/wallpapers/`; the last choice is restored when i3 starts.

To add a repository wallpaper:

```bash
cp path/to/image.webp ~/dotfiles/wallpapers/my-wallpaper.webp
cd ~/dotfiles
./install.sh wallpapers
```

To keep a wallpaper private to one machine, copy it directly to `~/Pictures/wallpapers/` instead. Repository updates preserve extra local files in that directory.

## Keybindings

`Mod` is the Super/Windows key.

### i3 and Rofi

| Key | Action |
| --- | --- |
| `Mod+Return` | Open Kitty |
| `Mod+d` | Open the Rofi application launcher |
| `Mod+p` | Open dmenu |
| `Mod+t` | Open the Rofi theme picker |
| `Mod+Shift+b` | Open the Rofi wallpaper picker |
| `Mod+v` | Open Greenclip history in Rofi |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move the focused window |
| `Mod+1…0` | Switch to workspace 1…10 |
| `Mod+Shift+1…0` | Move a window to workspace 1…10 |
| `Mod+a` / `Mod+-` | Split vertically / horizontally |
| `Mod+s/w/e` | Stacking / tabbed / toggle split layout |
| `Mod+f` | Toggle fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Escape` | Lock the screen |
| `Mod+Shift+s` | Capture an area with Flameshot |
| `Mod+Shift+f` | Capture the full screen |
| `Mod+m` | Open ncspot |
| `Mod+Shift+a` | Open ani-cli |
| `Mod+Shift+v` | Open lobster |

Polybar’s Wi-Fi, Bluetooth, and power modules open Rofi menus when clicked. Right-click the volume module to open `pavucontrol`.

### tmux

The prefix is `Ctrl+g`.

| Key | Action |
| --- | --- |
| `Ctrl+g`, `p`, `n` | Split a pane to the right |
| `Ctrl+g`, `p`, `l/r/u/d` | Split left/right/up/down in the current directory |
| `Ctrl+g`, `t`, `n` | Create a window/tab |
| `Ctrl+g`, `t`, `h/l` | Select previous/next window |
| `Ctrl+h/j/k/l` | Navigate panes and Neovim splits |
| `Alt+H/L` | Select previous/next tmux window |
| `Ctrl+g`, `[` | Enter vi-style copy mode |

Shell aliases: `tn <name>` creates a session, `ta <name>` attaches, `tl` lists, and `tk <name>` kills one. TPM installs Catppuccin, vim-tmux-navigator, yank, resurrect, continuum, and sensible into `~/.tmux/plugins/`; plugin checkouts are not repository submodules.

## Tool versions

The source of truth is `mise/.config/mise/config.toml`. It currently includes Node.js 24/22 LTS, Java 21/17, Python 3.12, Maven 3.9, Gradle 8, pnpm, Neovim, GitHub CLI, lazygit, lazydocker, and the CLI/TUI tools listed there.

Add a tool to the manifest, then run:

```bash
./update.sh --local
```

## Repository layout

```text
.
├── install.sh                  # full and component installer
├── update.sh                   # non-destructive update workflow
├── install/                    # package installers and Stow deployer
├── scripts/verify.sh           # local/CI verification entry point
├── tests/                      # temp-HOME integration tests
├── .github/workflows/          # GitHub Actions verification
├── mise/.config/mise/          # language and tool manifest
├── i3/.config/i3/              # i3 config and session scripts
├── polybar/.config/polybar/    # bar launcher and Rofi helper scripts
├── themes/.config/themes/      # source themes, templates, and renderer
├── wallpapers/                 # wallpapers copied during setup/update
├── pvim/.config/pvim/          # the only Git submodule
└── <package>/<target path>     # GNU Stow package layout
```

To add another managed config, mirror its home-relative path in a package directory, add the package name to `DOTFILES_PACKAGES` in `install/deploy.sh`, and add a fresh/existing-home assertion when the behavior is significant.

## Contributing

1. Fork and clone with `--recurse-submodules`.
2. Create a focused branch.
3. Run `./scripts/verify.sh`.
4. Use [Conventional Commits](https://www.conventionalcommits.org/) such as `fix(update): preserve dirty worktrees`.
5. Open a pull request describing behavior changes and manual desktop testing.

Project-specific engineering and commit rules are in [`CLAUDE.md`](./CLAUDE.md). CI must pass before changes reach `main`.

## Troubleshooting

- Restore an overwritten conflict from the newest directory under `~/.local/state/dotfiles/backups/`.
- Run `./install.sh stow --dry-run` to inspect link conflicts.
- Run `./update.sh --check` to diagnose repository or config failures without deployment.
- If an update exits `2`, inspect `git status`; local work was preserved and remote sync was skipped.
- If a plugin is missing, run `~/.tmux/plugins/tpm/bin/install_plugins` or `./update.sh`.
- Restart the shell after Zsh changes; use `tmux source-file ~/.tmux.conf` after tmux-only edits.

## License

[MIT](./LICENSE)
