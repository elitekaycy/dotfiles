# elitekaycy/dotfiles

[![Verify dotfiles](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml/badge.svg)](https://github.com/elitekaycy/dotfiles/actions/workflows/verify.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Shell: Bash/Zsh](https://img.shields.io/badge/shell-bash%20%2F%20zsh-89b4fa.svg)](./zsh)

### An i3 workstation, themed from one source of truth.

i3 + Polybar + Rofi + Kitty + tmux + Zsh + Neovim (pvim) — every app rendered from a single theme file, every user action a `dots-*` command. Built for daily use, kept lean, verified in CI.

[Install](#install) · [Commands](./docs/commands.md) · [Themes](./docs/themes.md) · [Keybindings](./docs/keybindings.md) · [Architecture](./docs/architecture.md)

![Desktop running these dotfiles](./docs/dotfiles.png)

* * *

```bash
git clone --recurse-submodules https://github.com/elitekaycy/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

That's the whole install: packages, symlinks, wallpapers, theme, TPM plugins and pvim, on Ubuntu/Debian, Fedora, or Arch.

## Why this exists

- **One theme source, zero hardcoded colours.** `themes/<id>.conf` defines ~20 colours; `dots-theme-set` renders Polybar, Kitty, Dunst, Rofi, i3, tmux and pvim from it in one shot. Switch theme, everything — including the lock screen and the SDDM login screen — follows.
- **Every action is a command, not a keybinding-only hack.** i3, Polybar and the shell all call the same `dots-*` scripts under `bin/.local/bin/`, so anything bound to a key is also typeable, scriptable and searchable from `dots-menu`.
- **Nothing generated is committed.** Rendered configs (`polybar/config.ini`, `kitty/theme.conf`, `dunst/dunstrc`, `rofi/config.rasi`, i3/tmux `theme.conf`) are runtime state, not tracked files — the repo stays a template, not a snapshot.
- **Updates never gamble with your worktree.** `./update.sh` only fast-forwards a clean branch; a dirty checkout is deployed as-is and the command exits non-zero instead of resetting, rebasing or stashing anything.
- **Deployed through Stow**, not copied — `install/deploy.sh` restows every package with `--no-folding`, and conflicting unmanaged files are moved (never deleted) into a timestamped backup directory.
- **Verified, not just eyeballed.** `./scripts/verify.sh` runs shell syntax, ShellCheck and a temp-`HOME` install/update matrix in CI before anything merges.

## Install

| Component | What it does |
| --- | --- |
| `./install.sh` | Full workstation setup |
| `./install.sh stow [--dry-run]` | Reconcile config symlinks only |
| `./install.sh setup` | Links, wallpapers, theme, TPM plugins, pvim |
| `./install.sh themes` | Render the saved theme (Tokyo Night on first use) |
| `./install.sh wallpapers` | Copy `wallpapers/` into `~/Pictures/wallpapers/` |
| `./install.sh core` / `i3` / `terminal` / `fonts` / `zsh` | System packages by area (`i3` also builds i3lock-color) |
| `./install.sh login` | SDDM + astronaut login screen; replaces GDM/LightDM, active after reboot |
| `./install.sh devtools` / `languages` | Everything in the mise manifest |
| `./install.sh docker` / `chrome` / `rust` / `nvidia` / `greenclip` / `slack` / `media` / `pritunl` | Optional extras |
| `./install.sh check` | Run the verification suite, change nothing |

Conflicting unmanaged files are moved (never deleted) to `~/.local/state/dotfiles/backups/<timestamp>/`. Log out after the first full install.

## Update

```bash
./update.sh                          # fast-forward, verify, restow, re-render theme, mise + TPM
./update.sh --local                  # skip git; apply the current checkout
./update.sh --local --configs-only   # links + theme + wallpapers only, no tool sync
./update.sh --check                  # fetch + verify, deploy nothing
```

## Documentation

- **[docs/commands.md](./docs/commands.md)** — every `dots-*` command
- **[docs/themes.md](./docs/themes.md)** — theme list, adding a theme, wallpapers, lock/login, dark mode
- **[docs/keybindings.md](./docs/keybindings.md)** — the full i3/tmux/Polybar reference
- **[docs/architecture.md](./docs/architecture.md)** — how the theming pipeline and repo layout fit together
- **[docs/secrets.md](./docs/secrets.md)** — `pass`-backed secret storage via `dots-secret`
- **[docs/desktop.md](./docs/desktop.md)** — per-output monitor layouts
- **[docs/troubleshooting.md](./docs/troubleshooting.md)** — common fixes

## Verify before committing

```bash
./scripts/verify.sh
```

Conventions and commit rules: [`CLAUDE.md`](./CLAUDE.md).

## License

[MIT](./LICENSE)
