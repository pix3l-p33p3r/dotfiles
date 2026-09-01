#!/usr/bin/env bash
# Compat for leftover upgrade() that called this path.
: "${NH_FLAKE:=/home/pixel-peeper/dotfiles}"
exec nh home switch "$NH_FLAKE" -c 'pixel-peeper@alucard' "$@"
