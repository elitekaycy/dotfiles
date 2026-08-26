# Troubleshooting

- Theme looks half-applied → `dots-theme-set $(dots-theme-current)`; check `~/.config/<app>/theme.conf` exists.
- Wallpaper missing after a theme switch → `./install.sh wallpapers` (the theme directory in `~/Pictures/wallpapers/` is empty).
- A `dots-*` command is missing → `./install.sh stow`.
- Login screen not themed → `dots-login-sync` (needs `./install.sh login` first); the font is `JetBrainsMono Nerd Font` copied to `/usr/local/share/fonts/`.
- Lock screen is a flat colour → i3lock-color is missing: `./install.sh i3`.
- Restore an overwritten file from `~/.local/state/dotfiles/backups/`.
- `./update.sh` exits `2` → local changes were preserved and upstream sync skipped; commit and rerun.
