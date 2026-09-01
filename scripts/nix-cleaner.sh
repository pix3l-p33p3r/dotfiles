#!/usr/bin/env bash
# Compat for leftover `alias clean=$HOME/dotfiles/scripts/nix-cleaner.sh`.
exec nix-clean "$@"
