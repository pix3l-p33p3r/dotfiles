#!/usr/bin/env bash
# Free ephemeral Lean/Rust toolchains after a project build.
set -euo pipefail

HYNIX_ELAN="${HYNIX_ELAN:-/media/elel-yak/hynix256/toolchains/elan}"
GOINFRE_ELAN="${GOINFRE:-/goinfre/$USER}/elan"
GOINFRE_RUSTUP="${GOINFRE:-/goinfre/$USER}/rustup"

usage() {
  echo "usage: toolchain-gc {lean|rust|all|status}"
  echo "  lean  — wipe elan toolchains (hynix + leftover goinfre)"
  echo "  rust  — drop .devenv/.direnv GC roots here + nix-collect-garbage -d"
  echo "  all   — lean + rust"
  echo "  status — disk use of toolchain dirs"
}

status() {
  du -sh "$HYNIX_ELAN" "$GOINFRE_ELAN" "$GOINFRE_RUSTUP" \
    "${GOINFRE:-/goinfre/$USER}/cargo" \
    .devenv .direnv 2>/dev/null || true
  df -h /goinfre /media/elel-yak/hynix256 /nix 2>/dev/null || true
}

gc_lean() {
  echo "wiping lean toolchains…"
  rm -rf "$HYNIX_ELAN/toolchains" "$HYNIX_ELAN/tmp" \
    "$GOINFRE_ELAN/toolchains" "$GOINFRE_ELAN/tmp"
  # keep elan bin/settings if present; only multi-GB toolchains go
  echo "lean toolchains removed (elan launcher kept if any)"
}

gc_rust() {
  echo "dropping local devenv/direnv roots…"
  rm -rf .devenv .direnv
  if command -v nix-collect-garbage >/dev/null; then
    nix-collect-garbage -d
  else
    echo "nix-collect-garbage not found" >&2
  fi
  # legacy rustup on goinfre (no longer needed with nix rustc)
  if [[ -d "$GOINFRE_RUSTUP" ]]; then
    rm -rf "$GOINFRE_RUSTUP"
    echo "removed $GOINFRE_RUSTUP"
  fi
}

cmd="${1:-}"
case "$cmd" in
  lean) gc_lean ;;
  rust) gc_rust ;;
  all) gc_lean; gc_rust ;;
  status) status ;;
  *) usage; exit 1 ;;
esac
