#!/usr/bin/env bash
# Quick status for WinApps VM setup progress.
set -euo pipefail

VM_NAME="${WINAPPS_VM_NAME:-RDPWindows}"
VM_DIR="${WINAPPS_VM_DIR:-$HOME/VMs}"

echo "=== WinApps setup status ==="
echo

for iso in virtio-win.iso win11x64.iso; do
  path="$VM_DIR/isos/$iso"
  if [[ -f "$path" ]]; then
    printf '  %-16s %s\n' "$iso" "$(du -h "$path" | cut -f1)"
  else
    printf '  %-16s missing\n' "$iso"
  fi
done

esd_part="$(find "$VM_DIR/isos" -maxdepth 1 -name '*.esd.part' 2>/dev/null | head -1)"
esd_done="$(find "$VM_DIR/isos" -maxdepth 1 -name '*.esd' -size +3G 2>/dev/null | head -1)"
convert_log="$VM_DIR/esd-convert.log"
if pgrep -f "winapps-esd-to-iso" >/dev/null 2>&1; then
  printf '  %-16s %s\n' "win11.iso" "converting (see esd-convert.log)"
elif [[ -n "$esd_part" ]]; then
  printf '  %-16s %s (downloading)\n' "win11.esd" "$(du -h "$esd_part" | cut -f1)"
elif [[ -n "$esd_done" ]] && [[ ! -f "$VM_DIR/isos/win11x64.iso" ]]; then
  printf '  %-16s %s (run: winapps-esd-to-iso.sh)\n' "win11.esd" "$(du -h "$esd_done" | cut -f1)"
fi

if [[ -f "$convert_log" ]]; then
  echo
  echo "  Conversion log:"
  tail -1 "$convert_log" | tr '\r' '\n' | tail -1 | sed 's/^/    /'
fi

echo
if virsh dominfo "$VM_NAME" &>/dev/null; then
  virsh dominfo "$VM_NAME" | grep -E 'Name|State'
else
  echo "  VM: not created yet"
fi

echo
if [[ -f "$VM_DIR/CREDENTIALS.txt" ]]; then
  echo "  Credentials: $VM_DIR/CREDENTIALS.txt"
else
  echo "  Credentials: pending (created when VM is provisioned)"
fi

if [[ -f "$VM_DIR/create-vm.log" ]]; then
  echo
  echo "  VM create log:"
  tail -3 "$VM_DIR/create-vm.log" | sed 's/\r/\n/g' | tail -3 | sed 's/^/    /'
fi
