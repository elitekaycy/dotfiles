---
name: dev-guidelines
description: Development dos and don'ts for this dotfiles repo - invariants, verification, shell standards, commit conventions, and commit hygiene. Use before making changes or committing in this repository.
---

# dotfiles dev guidelines

This is the working checklist for changing this repository. It distills `CLAUDE.md` (the source of truth — re-read it if this skill and that file ever disagree) into a quick pre-flight and pre-commit pass.

## Before changing anything

- **One theme source drives every app.** Never hardcode a colour in an app config. Add it to `themes/.config/themes/themes/<id>.conf` and, if every theme needs it, to the templates in `themes/.config/themes/templates/`.
- **Every user-facing action is a `dots-*` command** in `bin/.local/bin/`. i3, Polybar and the shell call those commands — don't add logic directly under `~/.config/<app>/` or inline in keybindings.
- **`pvim/.config/pvim` is the only git submodule.** tmux plugins belong to TPM under `~/.tmux/plugins/`, not to this repo.
- **Generated theme outputs are not tracked.** Polybar `config.ini`, Kitty `theme.conf`, Dunst `dunstrc`, Rofi `config.rasi`, i3 `theme.conf`, tmux `theme.conf`, and the selected theme file are runtime state — never `git add` them.
- **Existing keybindings are never changed.** New features get new chords, documented in the README keybinding tables (now `docs/keybindings.md`).
- **Wallpapers** live in `wallpapers/<theme-id>/` or `wallpapers/shared/` — never loose at the repo root.
- **Never overwrite or delete an unmanaged config** without first preserving it in the dotfiles backup directory (`~/.local/state/dotfiles/backups/<timestamp>/`).
- **The updater must not reset, rebase, clean, or auto-stash** a user's worktree. Clean branches may only fast-forward.
- **Don't add `mise prune`** to normal updates — tools outside the manifest may belong to the user, not this repo.

## Shell standards

- Bash for `*.sh` entry points; `set -Eeuo pipefail` in standalone orchestrators.
- Quote expansions unless word splitting is intentional and documented.
- Scripts are idempotent and non-interactive unless the operation inherently needs auth/`sudo`.
- Never hide a required operation behind `|| true` — surface failures.
- `command -v` before optional desktop integrations.
- Must pass ShellCheck with the repo's `.shellcheckrc`.

## Required verification

Run before every commit:

```bash
./scripts/verify.sh
```

Quick deployment preview: `./install.sh stow --dry-run`.

When changing install/update behavior, cover **both** an empty temp home and an existing home with conflicts. Tests must never write through the host's `HOME`, `XDG_CONFIG_HOME`, or `XDG_STATE_HOME` — use the harness in `tests/`.

## Commit conventions

```text
<type>(<scope>): <imperative summary>
```

Types: `feat` `fix` `docs` `test` `ci` `refactor` `chore`. Scope should be concrete: `install`, `update`, `themes`, `tmux`, `nvim`, `shell`, `docs`. Subject imperative, concise, no trailing period. Add a body only when the *why* isn't obvious from the diff.

Good: `fix(update): preserve dirty worktrees` · `feat(themes): add a rofi-selectable nord variant` · `ci(verify): test upgrades from an existing home`

Avoid: `update files`, `fix stuff`, `changes`.

## Commit hygiene

- No co-authored-by, signed-off-by, or attribution trailers.
- One logical change per commit — don't bundle unrelated fixes, generated files, personal state, or pvim submodule work into one commit.
- Never commit `config.ini`, `theme.conf`, `dunstrc`, `config.rasi`, runtime state (undo/swap/session files), or secrets (`.env`, tokens, passwords).
- Never commit the pvim submodule as dirty — leave local pvim runtime changes unstaged.
- Prefer `git add <file>` over `git add .` / `git add -A`.
- Review `git diff --staged` before every commit; unstage anything that looks wrong.
- Don't amend published commits — create a new one. Don't force-push to main.

## Change-specific notes

- **New theme**: add a `.conf` source file and matching wallpaper, then test CLI rendering with `--no-reload`.
- **New wallpaper**: descriptive lowercase filename, document a theme reference if applicable.
- **New Stow package**: add it to `DOTFILES_PACKAGES` and exercise it in temp-HOME tests.
- **Submodule bump**: publish the referenced commit in the pvim repo first, then update the gitlink here.
- **GitHub Actions**: pin official actions to a current major, keep workflow permissions read-only unless a job proves it needs more.

Keep install, selective install, local update, and CI behavior aligned with the README and `docs/` at all times — a behavior change that isn't reflected there is an incomplete change.
