# 1337 cluster: nix lives on goinfre via nix-user-chroot
# No-op on NixOS hosts (e.g., alucard) where /goinfre does not exist.
[[ -d "/goinfre/$USER" ]] || return 0

unalias nrs hms update check clean upgrade 2>/dev/null
unfunction nrs hms update check clean upgrade 2>/dev/null

nix-enter() { command nix-enter "$@"; }
nix-setup() { command nix-setup "$@"; }

# Enter nix namespace for one command or a shell
nsh() { nix-enter "$@"; }
nrs() { echo "not on NixOS — use: nix-up / nix-enter" >&2; return 1; }
hms() { echo "not on NixOS — edit ~/dotfiles-terminal then: nix-up" >&2; return 1; }
update() { nix-enter nix flake update --flake "$HOME/nix-config" "$@"; }
check() { nix-enter nix flake check "$HOME/nix-config" "$@"; }
clean() { nix-enter nix-collect-garbage -d "$@"; }

# Prefer goinfre apps
alias cursor='cursor'
alias kitty='kitty'
