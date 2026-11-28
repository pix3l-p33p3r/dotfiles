#!/usr/bin/env bash
# Real file under ~/.local so it works outside nix-user-chroot.
# Absolute profile path avoids recursing back into this wrapper.
bin="$HOME/.nix-profile/bin/yazi"
if [[ -x "$bin" ]] && "$bin" --version >/dev/null 2>&1; then
  exec "$bin" "$@"
fi
exec "$HOME/.local/bin/nix-enter" "$bin" "$@"
