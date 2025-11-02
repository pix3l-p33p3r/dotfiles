#!/usr/bin/env bash
set -euo pipefail

# This script automates steps 1-2-3-4 for enabling Secure Boot with Lanzaboote on NixOS.
# It will:
# 1) Enable Lanzaboote + sbctl in machines/alucard/boot.nix (uncomment if present, else append).
# 2) Rebuild the system (with Secure Boot still disabled in firmware).
# 3) Create and enroll Secure Boot keys via sbctl.
# 4) Rebuild again to ensure signed UKIs are in place.

REPO_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
CFG="$REPO_ROOT/machines/alucard/boot.nix"
FLAKE="$REPO_ROOT"

echo "[1/4] Ensuring Lanzaboote + sbctl are enabled in: $CFG"

# Lanzaboote uses an external installer and requires the systemd-boot module to be disabled.
# Accept either: (a) systemd-boot enabled (classic flow), or (b) lanzaboote-enabled with systemd-boot disabled.
if ! grep -qE "^\s*boot\.lanzaboote\.enable\s*=\s*true;" "$CFG"; then
  # If Lanzaboote not yet enabled, at least ensure systemd-boot is present to avoid a broken state
  if ! grep -qE "^\s*boot\.loader\.systemd-boot\.enable\s*=\s*true;" "$CFG"; then
    echo "INFO: Neither lanzaboote nor systemd-boot explicitly enabled. Proceeding to enable lanzaboote."
  fi
fi

# Try to uncomment existing commented Lanzaboote lines first
sed -i \
  -e 's/^\s*#\s*boot\.lanzaboote\.enable\s*=\s*true;/  boot.lanzaboote.enable = true;/' \
  -e 's/^\s*#\s*programs\.sbctl\.enable\s*=\s*true;/  programs.sbctl.enable = true;/' \
  -e 's|^\s*#\s*boot\.lanzaboote\.pkiBundle\s*=\s*"/var/lib/sbctl";|  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";|' \
  "$CFG" || true

if ! grep -qE "^\s*boot\.lanzaboote\.enable\s*=\s*true;" "$CFG"; then
  echo "Appending Lanzaboote configuration to $CFG"
  tmpfile="$(mktemp)"
  # Insert block before the final closing brace
  awk '
    BEGIN{inserted=0}
    /}\s*$/ && inserted==0 { 
      print "  # ───── Lanzaboote (Secure Boot with UKI) ─────";
      print "  # Disable systemd-boot module when using Lanzaboote external installer";
      print "  boot.loader.systemd-boot.enable = lib.mkForce false;";
      print "  boot.lanzaboote.enable = true;";
      print "  programs.sbctl.enable = true;";
      print "  boot.lanzaboote.pkiBundle = \"/var/lib/sbctl\";";
      inserted=1
    }
    {print}
  ' "$CFG" > "$tmpfile"
  mv "$tmpfile" "$CFG"
fi

echo "[2/4] Rebuilding system (Secure Boot still disabled in firmware)"
sudo nixos-rebuild switch --flake "$FLAKE#alucard"

echo "[3/4] Creating and enrolling Secure Boot keys with sbctl"
if ! command -v sbctl >/dev/null 2>&1; then
  echo "ERROR: sbctl not found. Ensure programs.sbctl.enable = true; and rebuild." >&2
  exit 1
fi

sudo sbctl status || true
if ! sudo sbctl list-keys >/dev/null 2>&1; then
  sudo sbctl create-keys
fi

# Enroll keys into firmware; -m uses the machine owner key path
sudo sbctl enroll-keys -m
sudo sbctl verify || true

echo "[4/4] Rebuilding again to ensure signed UKIs are installed"
sudo nixos-rebuild switch --flake "$FLAKE#alucard"

echo
echo "Done. Next steps:"
echo "  - Reboot and press F1 (ThinkPad BIOS) -> Security -> Secure Boot -> Enable"
echo "  - Save & Exit, then boot NixOS entry"
echo "  - Keep a NixOS USB handy for recovery the first time"


