# ── Waydroid (Android on Wayland) ─────────────────────────────────────────

alias android="$HOME/dotfiles/scripts/waydroid-setup.sh"
alias android-ui='waydroid session start 2>/dev/null; waydroid show-full-ui'
alias android-apps='waydroid app list'
android-launch() {
  if [[ $# -lt 1 ]]; then
    echo "usage: android-launch <package.activity>" >&2
    echo "hint: android-apps" >&2
    return 1
  fi
  waydroid session start 2>/dev/null || true
  waydroid app launch "$1"
}
