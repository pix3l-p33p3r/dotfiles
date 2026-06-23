# Scripts

Utility scripts for the NixOS dotfiles. Run from the repo root unless noted.

```bash
cd ~/dotfiles
./scripts/<name>.sh
```

## Daily / maintenance

| Script | Sudo | Purpose |
|--------|------|---------|
| `home-manager-switch.sh` | no | Wrapper for `home-manager switch --flake .#pixel-peeper@alucard` |
| `nix-cleaner.sh` | no | Prune old generations and run garbage collection (alias: `clean`) |
| `security-scan.sh` | no | AIDE integrity check + Lynis audit (alias: `secscan`) |
| `check-hw-accel.sh` | no | Verify Intel VA-API / Vulkan / OpenCL — see [HARDWARE-ACCELERATION.md](../docs/machines/alucard/HARDWARE-ACCELERATION.md) |

## Hyprpanel toggles (Wayle)

Used by the network widget in Hyprpanel:

| Script | Purpose |
|--------|---------|
| `firewall-status.sh` / `firewall-toggle.sh` | nftables firewall state |
| `dns-status.sh` / `dns-toggle.sh` | DNS profile switching |
| `nix-dns-recover.sh` | Recover DNS after a bad Nix rebuild |
| `hotspot-status.sh` / `hotspot-toggle.sh` / `hotspot-manage.sh` | Wi-Fi hotspot |

## Boot (one-time or rare)

| Script | Sudo | Purpose |
|--------|------|---------|
| `setup-secure-boot.sh` | yes | Lanzaboote + sbctl first-time Secure Boot setup |
| `cleanup-legacy-boot.sh` | yes | Remove stale `/boot/EFI/nixos/` entries after Lanzaboote migration |

## Filesystem migration (one-time — completed on alucard)

| Script | Sudo | Purpose |
|--------|------|---------|
| `backup-before-migration.sh` | no | Back up SSH/GPG/tasks before migration |
| `migrate-ext4-to-btrfs.sh` | yes | Live-ISO ext4 → Btrfs conversion |

See [MIGRATE-EXT4-TO-BTRFS.md](../docs/MIGRATE-EXT4-TO-BTRFS.md) for the full procedure.

## WinApps (Windows apps in Hyprland)

Full guide: [docs/WINAPPS.md](../docs/WINAPPS.md)

| Script | Purpose |
|--------|---------|
| `winapps-create-vm.sh` | Download ISOs, create `RDPWindows` VM, open virt-manager (alias: `winapps-vm`) |
| `winapps-status.sh` | ISO / VM / credential progress |
| `winapps-esd-to-iso.sh` | Convert a Microsoft `.esd` download to installable ISO (optional) |
| `winapps-windows-oem.bat` | Run inside Windows as Admin — WinApps OEM setup |
| `rofi-winapps.sh` | Rofi launcher (`Super+Shift+W`) |

## Waydroid

| Script | Purpose |
|--------|---------|
| `waydroid-setup.sh` | Init / start / UI helpers (alias: `android`) |
| `rofi-waydroid.sh` | Rofi app picker for Android apps |

## Rofi helpers

| Script | Bound in Hyprland |
|--------|-------------------|
| `rofi-winapps.sh` | `Super+Shift+W` |
| `rofi-waydroid.sh` | Waydroid menu |
