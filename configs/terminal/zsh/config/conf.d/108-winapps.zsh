# ── WinApps (Windows VM / Comet browser) ─────────────────────────────────────

alias winapps-docs='$PAGER "$HOME/dotfiles/scripts/WINAPPS.md"'
alias winapps-vm='$HOME/dotfiles/scripts/winapps-create-vm.sh'
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
