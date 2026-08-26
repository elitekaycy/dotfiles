# Architecture

## How it fits together

```text
themes/<id>.conf  ──►  dots-theme-set  ──►  polybar · kitty · dunst · rofi · i3 · tmux · pvim · wallpaper · lock · login
                            ▲
   Mod+t / Mod+Ctrl+Shift+Space ── dots-theme-menu (rofi)
   Mod+Ctrl+t ──────────────────── dots-theme-next
   Mod+Alt+Space ───────────────── dots-menu (hub: apps, theme, wallpaper, sessions, wifi, bluetooth, …)
```

- **One theme source** (`themes/.config/themes/themes/<id>.conf`) defines ~20 colours. `dots-theme-set` renders every app template from it and reloads the desktop. Nothing is hardcoded per app.
- **Per-theme wallpapers** live in `wallpapers/<theme-id>/`; `wallpapers/shared/` works with any theme. Switching theme switches wallpaper; `Mod+Ctrl+Space` cycles within the theme.
- **Lock and login match the theme.** `dots-lock` is i3lock-color (blurred desktop, clock, ring in the theme colours); the login screen is SDDM + [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme), re-rendered by `dots-login-sync` with the theme colours and the current wallpaper on every switch.
- **Every picker is Rofi** and every action is a `dots-*` command, so i3, Polybar and the shell all call the same thing.
- **Stow deploys** each package without folding directories; generated files are user state, never committed.

## Repository layout

```text
.
├── install.sh / update.sh        # entry points
├── install/                      # package installers, Stow deployer (DOTFILES_PACKAGES), setup steps
├── scripts/verify.sh             # local + CI verification
├── tests/                        # temp-HOME integration tests
├── bin/.local/bin/dots-*         # all commands
├── themes/.config/themes/        # themes/<id>.conf + templates/<app>.template
├── wallpapers/<theme-id>/        # per-theme wallpapers, plus shared/
├── i3/  polybar/  kitty/  tmux/  picom/  zsh/  bash/  git/  mise/  broot/  vim/  idea/  nvim/
└── pvim/.config/pvim/            # Neovim config (git submodule)
```

Generated and untracked: `polybar/config.ini`, `kitty/theme.conf`, `dunst/dunstrc`, `rofi/config.rasi`, `i3/theme.conf`, `tmux/theme.conf`, `nvim/lazyvim.json`.

## Update behavior

```bash
./update.sh                          # fast-forward, verify, restow, re-render theme, mise + TPM
./update.sh --local                  # skip git; apply the current checkout
./update.sh --local --configs-only   # links + theme + wallpapers only, no tool sync
./update.sh --check                  # fetch + verify, deploy nothing
```

A dirty checkout is never reset, rebased or stashed; it is deployed as-is and the command exits `2`. Clean branches only ever fast-forward — the updater never resets, rebases, cleans, or auto-stashes a user worktree.
