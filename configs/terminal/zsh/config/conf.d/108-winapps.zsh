# ── WinApps ───────────────────────────────────────────────────────────────
# VM helpers are store binaries from configs/desktop/winapps.

alias winapps-docs='$PAGER "$HOME/dotfiles/docs/WINAPPS.md"'
alias winapps-vm='winapps-create-vm'
comet() {
  local app
  app=$(find "$HOME/.local/share/applications" -maxdepth 1 -iname '*comet*.desktop' -print -quit)
  if [[ -n "$app" ]]; then
    gtk-launch "$(basename "$app" .desktop)"
  else
    echo "Run winapps-setup --user --add-apps after installing Comet in Windows" >&2
    return 1
  fi
}
alias windows-vm='winapps-launcher'
