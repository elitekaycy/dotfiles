# CLAUDE.md

This file defines repository conventions for coding agents and contributors.

## Project invariants

- `pvim/.config/pvim` is the only Git submodule. tmux plugins belong to TPM under `~/.tmux/plugins/`.
- Generated theme outputs are not tracked: Polybar `config.ini`, Kitty `theme.conf`, Dunst `dunstrc`, Rofi `config.rasi`, and the selected theme are runtime state.
- Deploy configs through `install/deploy.sh` with GNU Stow `--restow --no-folding`.
- Never overwrite or delete an unmanaged config without first preserving it in the dotfiles backup directory.
- The updater must not reset, rebase, clean, or auto-stash a user worktree. Clean branches may only fast-forward.
- Do not add `mise prune` to normal updates; tools outside the manifest may belong to the user.
- Keep full install, selective install, local update, and CI behavior aligned with the README.

## Required verification

Run before every commit:

```bash
./scripts/verify.sh
```

For a quick deployment preview:

```bash
./install.sh stow --dry-run
```

When changing install/update behavior, cover both an empty temporary home and an existing home with conflicts. Tests must never write through the host's `HOME`, `XDG_CONFIG_HOME`, or `XDG_STATE_HOME`.

## Shell standards

- Use Bash for `*.sh` entry points and `set -Eeuo pipefail` for standalone orchestrators.
- Quote expansions unless intentional word splitting is documented.
- Keep scripts idempotent and non-interactive unless the operation inherently requires authentication or `sudo`.
- Surface failures; do not hide a required operation behind `|| true`.
- Use `command -v` before optional desktop integrations.
- Pass ShellCheck with the repository `.shellcheckrc`.

## Conventional commits

Use this format:

```text
<type>(<scope>): <imperative summary>
```

Allowed common types:

- `feat`: new user-visible capability
- `fix`: corrected behavior or reliability
- `docs`: documentation only
- `test`: test coverage only
- `ci`: workflow or automation changes
- `refactor`: behavior-preserving restructuring
- `chore`: maintenance that fits no type above

Use a concrete scope such as `install`, `update`, `themes`, `tmux`, `nvim`, `shell`, or `docs`. Keep the subject concise, imperative, and without a trailing period. Add a body when the reason, migration, risk, or user impact is not obvious.

Good examples:

```text
fix(update): preserve dirty worktrees
feat(themes): add a rofi-selectable nord variant
ci(verify): test upgrades from an existing home
```

Avoid vague subjects such as `update files`, `fix stuff`, or `changes`. Keep commits focused; do not mix unrelated generated files, personal state, or nested submodule work into a dotfiles commit.

## Commit hygiene

- No co-authored-by trailers, signed-off-by, or attribution footers.
- One logical change per commit. Do not bundle unrelated fixes.
- Never commit generated files (config.ini, theme.conf, dunstrc, config.rasi), runtime state (undo files, swap files, session data), or secrets (.env, tokens, passwords).
- Never commit the pvim submodule as dirty. If pvim has local runtime changes, leave it unstaged.
- Subject line: imperative mood, under 72 characters, no trailing period.
- Body: explain *why*, not *what*. The diff shows what changed; the body explains the motivation, trade-off, or risk.
- Review `git diff --staged` before every commit. If a file looks wrong, unstage it.
- Prefer `git add <file>` over `git add .` to avoid accidentally staging unrelated changes.
- Do not amend published commits. Create a new commit instead.
- Do not force-push to main.

## Change-specific rules

- Theme: add a `.conf` source file and matching wallpaper, then test CLI rendering with `--no-reload`.
- Wallpaper: use a descriptive lowercase filename and document a theme reference when applicable.
- Stow package: add it to `DOTFILES_PACKAGES` and exercise it in temp-HOME tests.
- Submodule: publish the referenced commit in its own repository before updating the parent gitlink.
- GitHub Actions: pin official actions to a current major and keep workflow permissions read-only unless a job proves it needs more.
