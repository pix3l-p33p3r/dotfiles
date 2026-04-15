# ── NixOS / Home Manager workflow ─────────────────────────────────────────

alias clean="$HOME/dotfiles/scripts/nix-cleaner.sh"

# System rebuild — delegate job count to nix.settings.max-jobs (auto), suppress output
alias nrs="sudo nixos-rebuild switch --flake '$HOME/dotfiles#alucard' --no-reexec --no-build-output"

# Home Manager rebuild (delegates to script so flags stay correct even if this
# file was not yet redeployed into ~/.config/zsh — avoids --no-build-output etc.)
hms() {
  bash "$HOME/dotfiles/scripts/home-manager-switch.sh" "$@"
}

alias update="cd $HOME/dotfiles && nix flake update"

# Full upgrade: use bash + repo script for HM so it never uses a stale hms() body
upgrade() {
  cd "$HOME/dotfiles" || return 1
  nrs || return 1
  bash "$HOME/dotfiles/scripts/home-manager-switch.sh" || return 1
  clear
  fastfetch
}

alias check="nix flake check"

# ── Nix helpers ────────────────────────────────────────────────────────────
alias nsize="nix path-info -Sh /run/current-system"
alias nsearch="nix search nixpkgs"
alias nwhy="nix why-depends"
alias nfdiff="nix flake diff"
alias nbuild="cd $HOME/dotfiles && nix build .#"
alias mcp="nix run github:utensils/mcp-nixos"
