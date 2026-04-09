#!/usr/bin/env bash
# Home Manager switch with only flags the HM CLI supports.
# Invoked via `bash` from upgrade/hms so a stale zsh function cannot pass
# nixos-rebuild-only options (e.g. --no-build-output).
set -euo pipefail

flake="${HM_FLAKE:-$HOME/dotfiles#pixel-peeper@alucard}"
backup_suffix="backup-$(date +%Y%m%d-%H%M%S)"

# Strip flags only nixos-rebuild understands (muscle memory / old hms()).
args=()
for _arg in "$@"; do
  case $_arg in
    --no-build-output) ;;
    *) args+=("$_arg") ;;
  esac
done

exec home-manager switch --flake "$flake" -b "$backup_suffix" "${args[@]}"
