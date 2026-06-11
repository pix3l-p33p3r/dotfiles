# WinApps — Comet browser on Hyprland (libvirt)

Run **Perplexity Comet** (and other Windows apps) as native-feeling windows via [WinApps](https://github.com/winapps-org/winapps) + a **Windows 11 Pro** VM.

## Prerequisites (after `nrs` + `hms`)

- `virt-manager`, `winapps`, `winapps-launcher`, `wlfreerdp`
- User in `libvirtd` + `kvm` groups (re-login after first rebuild)
- `~/.config/winapps/winapps.conf` — edit `RDP_USER` and password

## 1. Download ISOs

| File | URL |
|------|-----|
| Windows 11 **Pro** ISO | https://www.microsoft.com/software-download/windows11 |
| VirtIO drivers ISO | https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso |

> **Home** editions cannot host RDP apps — use **Pro**, Enterprise, or Server.

## 2. Create the VM in virt-manager

1. Open **Virtual Machine Manager** → **+** → Local install media.
2. Pick the Windows ISO; enable auto-detect.
3. **2 CPUs**, **4096 MB** RAM (minimum; 8192 MB nicer for Comet).
4. Disk: 64 GB+ qcow2.
5. Name the VM **`RDPWindows`** (or set `VM_NAME` in `winapps.conf`).
6. Check **Customize configuration before install**:
   - CPUs → **Copy host CPU configuration**
   - Add CD-ROM with **virtio-win.iso**
   - Firmware: **UEFI** + **TPM** (enabled via NixOS `swtpm`)
   - XML clock (reduce idle CPU): keep only `hypervclock` timer — see [WinApps libvirt guide](https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md)
   - Add Hyper-V enlightenments block (same guide)
   - Add QEMU guest agent channel (same guide)

Full XML snippets: https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md

## 3. Install Windows

- At “no disks”: **Load driver** → virtio ISO → `vioscsi` (Win11) driver.
- Win11 offline: `Shift+F10` → `OOBE\BYPASSNRO` → reboot → “I don’t have internet”.
- Create a **local account with password** (not PIN-only) — RDP requires it.
- Username suggestion: `winapps` (match `RDP_USER` in config).

## 4. Post-install inside Windows

1. Run **`virtio-win-guest-tools.exe`** from the virtio ISO (installs drivers + QEMU Guest Agent).
2. Enable RDP for applications:
   ```powershell
   # In PowerShell as Administrator — download WinApps OEM bundle:
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/winapps-org/winapps/main/oem/install.bat" -OutFile "$env:USERPROFILE\Downloads\install.bat"
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/winapps-org/winapps/main/oem/RDPApps.reg" -OutFile "$env:USERPROFILE\Downloads\RDPApps.reg"
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/winapps-org/winapps/main/oem/TimeSync.ps1" -OutFile "$env:USERPROFILE\Downloads\TimeSync.ps1"
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/winapps-org/winapps/main/oem/NetProfileCleanup.ps1" -OutFile "$env:USERPROFILE\Downloads\NetProfileCleanup.ps1"
   ```
   Then right-click **`install.bat`** → **Run as administrator** → reboot.

3. Install **Comet** from https://www.perplexity.ai/comet (Windows build).

## 5. Configure Linux side

Edit `~/.config/winapps/winapps.conf`:

```bash
RDP_USER="winapps"
RDP_PASS="YourWindowsPassword"
chmod 600 ~/.config/winapps/winapps.conf
```

Or store the password in SOPS (`winapps/rdp_password`) and uncomment the secret in `homes/pixel-peeper/sops.nix`.

Test RDP:

```bash
wlfreerdp /u:"winapps" /p:"…" /v:$(virsh domifaddr RDPWindows --source agent 2>/dev/null | awk '/ipv4/{print $4}' | cut -d/ -f1):3389 /cert:tofu
```

## 6. Register apps with WinApps

VM running, **not** logged in at the console (or close virt-manager viewer):

```bash
winapps-setup --user
```

Pick **Comet** (and anything else). Re-run after new installs:

```bash
winapps-setup --user --add-apps
```

## Daily use

| Action | Command / keybind |
|--------|-------------------|
| Rofi menu | `Super + Shift + W` |
| Comet directly | `winapps manual comet` |
| Tray / VM control | `winapps-launcher` |
| Full Windows desktop | `winapps windows` |

## Troubleshooting

- **“VM not found”** — name must be `RDPWindows` or match `VM_NAME`.
- **RDP fails** — delete stale certs: `rm ~/.config/freerdp/server/*.pem`
- **Black window on Wayland** — confirm `FREERDP_COMMAND="wlfreerdp"` in config.
- **App scan timeout** — increase `APP_SCAN_TIMEOUT` in `winapps.conf`.
