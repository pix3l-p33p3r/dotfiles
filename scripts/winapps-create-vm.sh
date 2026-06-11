#!/usr/bin/env bash
# Create the RDPWindows libvirt VM for WinApps (Comet browser).
set -euo pipefail

VM_NAME="${WINAPPS_VM_NAME:-RDPWindows}"
VM_DIR="${WINAPPS_VM_DIR:-$HOME/VMs}"
ISO_DIR="$VM_DIR/isos"
DISK_DIR="$VM_DIR/disks"
DISK_PATH="$DISK_DIR/${VM_NAME}.qcow2"
WIN_ISO="$ISO_DIR/win11x64.iso"
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"
CREDS_FILE="$VM_DIR/CREDENTIALS.txt"
CONF="$HOME/.config/winapps/winapps.conf"
MIDO="$ISO_DIR/Mido.sh"

log() { printf '[winapps-vm] %s\n' "$*"; }
die() { printf '[winapps-vm] ERROR: %s\n' "$*" >&2; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

ensure_network() {
  if ! virsh net-info default 2>/dev/null | grep -q "Active:.*yes"; then
    log "Starting libvirt default network (needs root once)…"
    run0 -- virsh net-start default
    run0 -- virsh net-autostart default
  fi
}

download_virtio() {
  [[ -s "$VIRTIO_ISO" ]] && return 0
  mkdir -p "$ISO_DIR"
  log "Downloading VirtIO drivers ISO…"
  curl -fL --retry 3 -o "$VIRTIO_ISO" \
    "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
}

download_windows() {
  [[ -s "$WIN_ISO" ]] && return 0
  mkdir -p "$ISO_DIR"
  if [[ ! -x "$MIDO" ]]; then
    log "Fetching Mido (official Microsoft ISO downloader)…"
    curl -fsSL -o "$MIDO" "https://raw.githubusercontent.com/ElliotKillick/Mido/master/Mido.sh"
    chmod +x "$MIDO"
  fi
  log "Downloading Windows 11 x64 ISO (~6 GB, may take a while)…"
  (cd "$ISO_DIR" && "$MIDO" win11x64)
  [[ -s "$WIN_ISO" ]] || die "Windows ISO download failed"
}

write_credentials() {
  mkdir -p "$VM_DIR" "$DISK_DIR"
  if [[ ! -s "$CREDS_FILE" ]]; then
    pass="$(openssl rand -base64 18 | tr -d '/+=' | head -c 20)"
    {
      echo "Windows local account (use during OOBE setup):"
      echo "  Username: winapps"
      echo "  Password: $pass"
      echo ""
      echo "Choose Windows 11 Pro during install (required for RDP apps)."
    } > "$CREDS_FILE"
    chmod 600 "$CREDS_FILE"
    log "Generated Windows credentials → $CREDS_FILE"
  fi

  mkdir -p "$(dirname "$CONF")"
  if [[ -L "$CONF" ]] || [[ ! -f "$CONF" ]]; then
    rm -f "$CONF"
    cp "$HOME/dotfiles/configs/desktop/winapps/winapps.conf.template" "$CONF"
  fi
  pass="$(sed -n 's/^  Password: //p' "$CREDS_FILE" | head -1)"
  sed -i "s/^RDP_USER=.*/RDP_USER=\"winapps\"/" "$CONF"
  sed -i "s/^RDP_PASS=.*/RDP_PASS=\"$pass\"/" "$CONF"
  chmod 600 "$CONF"
}

patch_vm_xml() {
  local tmp xml
  tmp="$(mktemp)"
  xml="$(mktemp)"
  virsh dumpxml "$VM_NAME" > "$xml"

  if ! grep -q "<hyperv>" "$xml"; then
    python3 - "$xml" <<'PY'
import sys
import xml.etree.ElementTree as ET

path = sys.argv[1]
tree = ET.parse(path)
root = tree.getroot()

def q(tag):
    return f"{{http://libvirt.org/schemas/domain/qemu/1.0}}{tag}"

features = root.find("features")
if features is None:
    features = ET.SubElement(root, "features")

hyperv = features.find("hyperv")
if hyperv is None:
    hyperv = ET.SubElement(features, "hyperv")

def set_state(name, value="on"):
    el = hyperv.find(name)
    if el is None:
        el = ET.SubElement(hyperv, name)
    el.set("state", value)

for name in (
    "relaxed", "vapic", "vpindex", "synic", "reset", "frequencies",
    "reenlightenment", "tlbflush", "ipi",
):
    set_state(name)

spinlocks = hyperv.find("spinlocks")
if spinlocks is None:
    spinlocks = ET.SubElement(hyperv, "spinlocks")
spinlocks.set("state", "on")
spinlocks.set("retries", "8191")

stimer = hyperv.find("stimer")
if stimer is None:
    stimer = ET.SubElement(hyperv, "stimer")
stimer.set("state", "on")
direct = stimer.find("direct")
if direct is None:
    direct = ET.SubElement(stimer, "direct")
direct.set("state", "on")

clock = root.find("clock")
if clock is None:
    clock = ET.SubElement(root, "clock")
clock.set("offset", "localtime")
for timer_name, present in (
    ("rtc", "no"), ("pit", "no"), ("hpet", "no"), ("kvmclock", "no"), ("hypervclock", "yes"),
):
    timer = clock.find(f"timer[@name='{timer_name}']")
    if timer is None:
        timer = ET.SubElement(clock, "timer")
        timer.set("name", timer_name)
    timer.set("present", present)

tree.write(path, encoding="unicode", xml_declaration=True)
PY
    virsh define "$xml"
    log "Applied Hyper-V enlightenments + clock tuning"
  fi

  rm -f "$xml" "$tmp"
}

create_vm() {
  if virsh dominfo "$VM_NAME" &>/dev/null; then
    log "VM '$VM_NAME' already exists — skipping creation"
    return 0
  fi

  log "Creating VM '$VM_NAME'…"
  virt-install \
    --connect qemu:///system \
    --name "$VM_NAME" \
    --memory 8192 \
    --vcpus 2 \
    --cpu host-passthrough \
    --machine q35 \
    --os-variant win11 \
    --boot uefi,hd,cdrom \
    --disk "path=$DISK_PATH,size=64,format=qcow2,bus=virtio" \
    --disk "path=$WIN_ISO,device=cdrom,bus=sata" \
    --disk "path=$VIRTIO_ISO,device=cdrom,bus=sata" \
    --network network=default,model=virtio \
    --graphics spice,listen=127.0.0.1 \
    --video virtio \
    --sound ich9 \
    --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis \
    --channel "unix,target.type=virtio,target.name=org.qemu.guest_agent.0" \
    --noautoconsole

  patch_vm_xml
}

print_next_steps() {
  cat <<EOF

══════════════════════════════════════════════════════════════
  RDPWindows VM is ready to install Windows
══════════════════════════════════════════════════════════════

  Credentials:  $CREDS_FILE
  WinApps conf: $CONF

  1. virt-manager should open — complete Windows 11 Pro setup:
     - Load virtio SCSI driver when no disk is shown
     - Shift+F10 → OOBE\\BYPASSNRO (skip Microsoft account)
     - User: winapps  /  password from CREDENTIALS.txt

  2. Inside Windows (after install):
     - Run virtio-win-guest-tools.exe from the virtio CD
     - Run scripts/winapps-windows-oem.bat as Administrator
     - Install Comet from https://www.perplexity.ai/comet
     - Reboot

  3. Back on Linux (VM on, NOT logged in at console):
     winapps-setup --user

  4. Launch Comet:  Super+Shift+W  or  comet

  Full guide: ~/dotfiles/scripts/WINAPPS.md
══════════════════════════════════════════════════════════════
EOF
}

main() {
  need virsh
  need virt-install
  need curl
  need openssl
  need python3
  need run0

  ensure_network
  download_virtio
  download_windows
  write_credentials
  create_vm

  if command -v notify-send >/dev/null; then
    notify-send -a winapps "RDPWindows ready" "Open virt-manager to install Windows — see ~/VMs/CREDENTIALS.txt"
  fi

  print_next_steps

  if command -v virt-manager >/dev/null; then
    virt-manager --connect qemu:///system --show-domain-console "$VM_NAME" &
  fi
}

main "$@"
