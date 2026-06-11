#!/usr/bin/env bash
# Wait for Windows media, convert ESD if needed, then create VM and open virt-manager.
set -euo pipefail

VM_DIR="${WINAPPS_VM_DIR:-$HOME/VMs}"
ISO_DIR="$VM_DIR/isos"
WIN_ISO="$ISO_DIR/win11x64.iso"
LOG="$VM_DIR/finish-when-ready.log"
ESD_TO_ISO="$HOME/dotfiles/scripts/winapps-esd-to-iso.sh"
CREATE_VM="$HOME/dotfiles/scripts/winapps-create-vm.sh"

exec > >(tee -a "$LOG") 2>&1

ready_esd() {
  local f
  f="$(find "$ISO_DIR" -maxdepth 1 -name '*.esd' ! -name '*.part' -size +3G -print -quit 2>/dev/null || true)"
  [[ -n "$f" && -f "$f" ]] || return 1
  printf '%s' "$f"
}

echo "[$(date)] Waiting for Windows install media…"

while [[ ! -s "$WIN_ISO" ]]; do
  if esd="$(ready_esd)"; then
    echo "[$(date)] ESD ready: $(basename "$esd") — converting to ISO"
    "$ESD_TO_ISO" "$esd" "$WIN_ISO"
    break
  fi
  part="$(find "$ISO_DIR" -maxdepth 1 -name '*.esd.part' 2>/dev/null | head -1)"
  if [[ -n "$part" ]]; then
    echo "[$(date)] Downloading… $(du -h "$part" | cut -f1)"
  else
    echo "[$(date)] No ESD yet — start: $CREATE_VM --download-only"
  fi
  sleep 60
done

echo "[$(date)] Windows ISO ready ($(du -h "$WIN_ISO" | cut -f1))"
exec "$CREATE_VM" --vm-only
