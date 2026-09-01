# ── NixOS / Home Manager (nh) ─────────────────────────────────────────────
# Functions, not aliases — aliases baked into an old session keep pointing
# at deleted ~/dotfiles/scripts/*.sh until exec zsh.
# Flake path: programs.nh.flake, with a fallback if session vars were skipped.

: "${NH_FLAKE:=/home/pixel-peeper/dotfiles}"
export NH_FLAKE

unalias nrs hms update check clean upgrade 2>/dev/null
unfunction nrs hms update check clean upgrade reload-dotfiles 2>/dev/null

nrs() { nh os switch "$NH_FLAKE" "$@" }
hms() { nh home switch "$NH_FLAKE" -c 'pixel-peeper@alucard' "$@" }
update() { nix flake update --flake "$NH_FLAKE" "$@" }
check() { nix flake check "$NH_FLAKE" "$@" }
clean() { command nix-clean "$@" }

upgrade() {
  nrs "$@" || return 1
  hms || return 1
  clean
}

reload-dotfiles() {
  local f
  for f in "$ZDOTDIR/conf.d"/*.zsh(N); do
    source "$f"
  done
}

# ── Nix helpers ────────────────────────────────────────────────────────────
alias nsize='nix path-info -Sh /run/current-system'
alias nsearch='nix search nixpkgs'
alias nwhy='nix why-depends'
alias nbuild='nix build'
alias mcp='nix run github:utensils/mcp-nixos'
