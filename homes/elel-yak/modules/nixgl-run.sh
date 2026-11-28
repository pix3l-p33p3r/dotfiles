#!/usr/bin/env bash
# Run a Nix profile binary under nixGLIntel, inside nix-user-chroot.
# Usage: nixgl-run <profile-bin-name> [args...]
# GNOME calls this from outside the chroot; we re-enter, then nixGLIntel.
set -euo pipefail
name="${1:?profile bin name}"
shift
if [[ -z "${NIX_USER_CHROOT:-}" ]]; then
  exec "$HOME/.local/bin/nix-enter" "$HOME/.local/bin/nixgl-run" "$name" "$@"
fi
gl="$HOME/.nix-profile/bin/nixGLIntel"
bin="$HOME/.nix-profile/bin/$name"
if [[ ! -x "$gl" || ! -x "$bin" ]]; then
  echo "nixgl-run: missing $gl or $bin" >&2
  exit 127
fi
exec "$gl" "$bin" "$@"
