#!/usr/bin/env bash
export SHELL=/bin/bash
export XDG_DATA_DIRS="${HOME}/.nix-profile/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
for _gs in "${HOME}/.nix-profile/share/gsettings-schemas"/*; do
  if [[ -d "$_gs" ]]; then
    XDG_DATA_DIRS="${_gs}:${XDG_DATA_DIRS}"
  fi
done
export XDG_DATA_DIRS
export GSETTINGS_SCHEMA_DIR="${HOME}/.nix-profile/share/gsettings-schemas/gsettings-desktop-schemas-51.0/glib-2.0/schemas${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"
if [[ -d "${HOME}/.nix-profile/etc/fonts" ]]; then
  export FONTCONFIG_PATH="${HOME}/.nix-profile/etc/fonts:${FONTCONFIG_PATH:-/etc/fonts}"
fi

bin="$HOME/.nix-profile/bin/codex-desktop"
flags=(--no-sandbox --disable-gpu)
if [[ -n "${NIX_USER_CHROOT:-}" ]]; then
  exec "$bin" "${flags[@]}" "$@"
fi
exec "$HOME/.local/bin/nix-enter" "$bin" "${flags[@]}" "$@"
