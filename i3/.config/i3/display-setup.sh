#!/usr/bin/env bash
# Apply the saved monitor layout for the connected outputs (see dots-monitors),
# falling back to "primary + others to the right" when none is saved.
set -Eeuo pipefail

command -v xrandr >/dev/null || exit 0
exec "$HOME/.local/bin/dots-monitors" apply
