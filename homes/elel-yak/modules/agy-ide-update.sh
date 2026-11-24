#!/usr/bin/env bash
# Update Antigravity IDE from github:Hy4ri/antigravity-flake + refresh 1337 parcel stub.
# Usage: agy-ide-update
set -euo pipefail

FLAKE="${HM_FLAKE:-$HOME/dotfiles-terminal/homes/elel-yak}"
GOINFRE="${GOINFRE:-/goinfre/$USER}"
FIX="$GOINFRE/agy-fix"

# Outside goinfre nix chroot → re-enter once.
if [[ -x "$HOME/.local/bin/nix-enter" ]]; then
  a="$(command stat -c '%d:%i' /nix 2>/dev/null || true)"
  b="$(command stat -c '%d:%i' "$GOINFRE/nix" 2>/dev/null || true)"
  if [[ -z "$a" || "$a" != "$b" ]]; then
    exec "$HOME/.local/bin/nix-enter" "$HOME/.local/bin/agy-ide-update" "$@"
  fi
fi

echo "==> nix flake lock --update-input antigravity"
nix flake lock --update-input antigravity --flake "$FLAKE"

echo "==> home-manager switch --flake $FLAKE#elel-yak"
home-manager switch --flake "$FLAKE#elel-yak"

rm -f "$FIX/stamp"
echo "==> done. Next: antigravity-ide <folder>"
echo "    (parcel stub refreshes on next launch)"
