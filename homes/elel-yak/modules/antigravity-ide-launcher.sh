#!/usr/bin/env bash
# Antigravity IDE on 1337: nix-user-chroot + FHS bwrap makes @parcel/watcher
# SIGSEGV (fileWatcher exit 139) when opening a folder. We launch a patched
# FHS script that bind-mounts a no-op JS stub over @parcel/watcher.
set -euo pipefail

export SHELL=/bin/bash
export GTK_USE_PORTAL=0
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

GOINFRE="${GOINFRE:-/goinfre/$USER}"
FIX="$GOINFRE/agy-fix"
STUB="$FIX/parcel-stub"
FLAGS=(--no-sandbox --disable-gpu)

# GNOME dock starts this outside nix-user-chroot, where /nix does not exist.
# Resolve store paths only after entering. Kitty is already inside, so this is a no-op there.
in_nix() {
  [[ -n "${NIX_USER_CHROOT:-}" ]] && return 0
  local a b
  a=$(stat -c '%d:%i' /nix 2>/dev/null || true)
  b=$(stat -c '%d:%i' "$GOINFRE/nix" 2>/dev/null || true)
  [[ -n "$a" && "$a" == "$b" ]]
}
if ! in_nix; then
  mkdir -p "$FIX"
  echo "$(date -Is) dock/outside → nix-enter args=$*" >> "$FIX/launch.log"
  exec "$HOME/.local/bin/nix-enter" "$HOME/.local/bin/antigravity-ide" "$@"
fi

refresh_patch() {
  mkdir -p "$STUB/build/Release"
  cat > "$STUB/package.json" <<'EOF'
{"name":"@parcel/watcher","version":"2.5.1","main":"index.js"}
EOF
  # Match @parcel/watcher wrapper.js surface (VS Code fileWatcher).
  # No native .node — that SIGSEGVs under nested nix-user-chroot + FHS bwrap.
  cat > "$STUB/index.js" <<'EOF'
'use strict';

function writeSnapshot(_dir, _snapshot, _opts) {
  return Promise.resolve();
}

function getEventsSince(_dir, _snapshot, _opts) {
  return Promise.resolve([]);
}

function unsubscribe(_dir, _fn, _opts) {
  return Promise.resolve();
}

async function subscribe(dir, fn, opts) {
  return {
    unsubscribe() {
      return unsubscribe(dir, fn, opts);
    },
  };
}

exports.writeSnapshot = writeSnapshot;
exports.getEventsSince = getEventsSince;
exports.subscribe = subscribe;
exports.unsubscribe = unsubscribe;
EOF
  cat > "$STUB/wrapper.js" <<'EOF'
'use strict';
// Real package: index.js loads native binding then createWrapper(binding).
// Stub: index.js is already the public API; keep require('./wrapper') safe.
exports.createWrapper = function createWrapper(binding) {
  return {
    writeSnapshot: binding.writeSnapshot.bind(binding),
    getEventsSince: binding.getEventsSince.bind(binding),
    subscribe: binding.subscribe.bind(binding),
    unsubscribe: binding.unsubscribe.bind(binding),
  };
};
EOF
  : > "$STUB/build/Release/watcher.node"

  local prof wrapped bwrap parcel
  prof=$(readlink -f "$HOME/.nix-profile/bin/antigravity-ide")
  wrapped="$(dirname "$prof")/.antigravity-ide-wrapped"
  bwrap=$(grep -o '/nix/store/[^ ]*/bin/bwrap' "$wrapped" | head -1)
  parcel=$(ls -d /nix/store/*/opt/antigravity/resources/app/node_modules/@parcel/watcher 2>/dev/null | sort | tail -1)
  if [[ -z "$bwrap" || -z "$parcel" || ! -f "$wrapped" ]]; then
    echo "antigravity-ide: could not locate FHS wrapper / parcel watcher" >&2
    exit 1
  fi
  cat > "$FIX/bwrap" <<EOF
#!/usr/bin/env bash
exec $(printf '%q' "$bwrap") \\
  --bind $(printf '%q' "$STUB") $(printf '%q' "$parcel") \\
  "\$@"
EOF
  chmod +x "$FIX/bwrap"
  # Rewrite absolute bwrap path to our injector
  sed "s|$bwrap|$FIX/bwrap|g" "$wrapped" > "$FIX/antigravity-ide-fhs.sh"
  # FHS replaces /usr, so /etc/localtime → /.host-etc/localtime →
  # /usr/share/zoneinfo/... is dangling. Lean's watchdog exits on that.
  # Drop the symlink and bind the real zone file (bwrap will not override either way).
  local tz
  tz=$(readlink -f /etc/localtime 2>/dev/null || true)
  if [[ -n "$tz" && -f "$tz" ]]; then
    sed -i 's| /etc/localtime||' "$FIX/antigravity-ide-fhs.sh"
    sed -i "s|^\\(.*container-init.*\\)|  --ro-bind $(printf '%q' "$tz") /etc/localtime \\\\\\n\\1|" \
      "$FIX/antigravity-ide-fhs.sh"
  fi
  chmod +x "$FIX/antigravity-ide-fhs.sh"
}

# Rebuild patch when profile ide changes
prof_now=$(readlink -f "$HOME/.nix-profile/bin/antigravity-ide" 2>/dev/null || true)
stamp="$FIX/stamp"
if [[ ! -x "$FIX/antigravity-ide-fhs.sh" || ! -f "$stamp" || "$(cat "$stamp" 2>/dev/null)" != "$prof_now" ]]; then
  mkdir -p "$FIX"
  refresh_patch
  printf '%s\n' "$prof_now" > "$stamp"
fi

exec "$FIX/antigravity-ide-fhs.sh" "${FLAGS[@]}" "$@"
