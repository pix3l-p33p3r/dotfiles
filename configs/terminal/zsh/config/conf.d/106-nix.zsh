# ── NixOS / Home Manager workflow ─────────────────────────────────────────

alias clean="$HOME/dotfiles/scripts/nix-cleaner.sh"

# System rebuild — delegate job count to nix.settings.max-jobs (auto), suppress output
alias nrs="sudo nixos-rebuild switch --flake '$HOME/dotfiles#alucard' --no-reexec --no-build-output"

# Home Manager rebuild with a timestamped backup suffix to avoid collisions
hms() {
  local backup_suffix="backup-$(date +%Y%m%d-%H%M%S)"
  home-manager switch --flake "$HOME/dotfiles#pixel-peeper@alucard" -b "$backup_suffix" --no-build-output
}

alias update="cd $HOME/dotfiles && nix flake update"

# Full upgrade: update flake → rebuild system → rebuild HM → clean → clear
alias upgrade="cd $HOME/dotfiles && nrs && hms && clean && clear && fastfetch"

alias check="nix flake check"

# ── Nix helpers ────────────────────────────────────────────────────────────
alias nsize="nix path-info -Sh /run/current-system"
alias nsearch="nix search nixpkgs"
alias nwhy="nix why-depends"
alias nfdiff="nix flake diff"
alias nbuild="cd $HOME/dotfiles && nix build .#"
alias mcp="nix run github:utensils/mcp-nixos"
