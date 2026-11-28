#!/usr/bin/env bash
# Install the host-side bootstrap into $HOME. Needs no Nix, so it also works on
# a reset home: clone the repo, run this, then goinfre-heal.
set -euo pipefail
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
units="$HOME/.config/systemd/user"

# Atomic replace: nix-setup may be executing the file being updated.
put() {
  local mode="$1" from="$2" to="$3"
  mkdir -p "$(dirname "$to")"
  install -m "$mode" "$from" "$to.new.$$"
  mv -f "$to.new.$$" "$to"
}

put 755 "$src/nix-enter" "$HOME/.local/bin/nix-enter"
put 755 "$src/nix-setup" "$HOME/.local/bin/nix-setup"
put 755 "$src/goinfre-heal" "$HOME/.local/bin/goinfre-heal"
put 644 "$src/goinfre-heal.service" "$units/goinfre-heal.service"
put 644 "$src/xprofile" "$HOME/.xprofile"
put 644 "$src/local-bin.conf" "$HOME/.config/environment.d/999-local-bin.conf"

mkdir -p "$units/graphical-session.target.wants"
ln -sfn "$units/goinfre-heal.service" "$units/graphical-session.target.wants/goinfre-heal.service"
/usr/bin/systemctl --user daemon-reload 2>/dev/null || true
