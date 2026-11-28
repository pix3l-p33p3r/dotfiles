#!/usr/bin/env bash
# Until goinfre-heal finishes on this machine, open the host terminal so there
# is always a shell to watch or fix the setup from.
if [[ -z "${NIX_USER_CHROOT:-}" && ! -f "/goinfre/$USER/.setup-ok" && -x /usr/bin/gnome-terminal ]]; then
  exec /usr/bin/gnome-terminal
fi
exec "$HOME/.local/bin/nixgl-run" kitty "$@"
