#!/usr/bin/env bash
# Bootstrap or start the Waydroid Android container.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: waydroid-setup.sh [init|gapps|start|ui|status]

  init    First-time setup (FOSS Android image, no Play Store)
  gapps   First-time setup with Google Play (requires accepting Google ToS)
  start   Start the Waydroid session
  ui      Open the full Android UI
  status  Show container / session state (default)

Examples:
  sudo waydroid-setup.sh init    # once, after nixos-rebuild
  waydroid-setup.sh start
  waydroid-setup.sh ui
EOF
}

cmd="${1:-status}"

case "$cmd" in
  init)
    exec sudo waydroid init
    ;;
  gapps)
    exec sudo waydroid init -s GAPPS
    ;;
  start)
    exec waydroid session start
    ;;
  ui)
    waydroid session start 2>/dev/null || true
    exec waydroid show-full-ui
    ;;
  status)
    waydroid status || true
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage >&2
    exit 1
    ;;
esac
