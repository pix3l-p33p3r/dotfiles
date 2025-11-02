# Scripts Directory

Utility scripts for managing the NixOS dotfiles system.

## Available Scripts

### `nix-cleaner.sh`

Cleans up old NixOS generations and frees disk space by removing:
- Old system generations (keeps last 3)
- Old boot entries
- Garbage collection

**Usage:**
```bash
./scripts/nix-cleaner.sh
```

### `setup-secure-boot.sh`

Automates the initial setup of Secure Boot with Lanzaboote:
1. Enables Lanzaboote in the configuration
2. Rebuilds the system
3. Creates and enrolls Secure Boot keys via sbctl
4. Rebuilds again to ensure signed UKIs are in place

**Usage:**
```bash
sudo ./scripts/setup-secure-boot.sh
```

**Important:** Run this before enabling Secure Boot in firmware for the first time.

### `cleanup-legacy-boot.sh`

Removes legacy boot entries from `/boot/EFI/nixos/` that are no longer needed when using Lanzaboote with UKIs.

**Why needed:** When migrating from systemd-boot to Lanzaboote, old kernel EFI files may remain in `/boot/EFI/nixos/`. These appear as "unsigned" in `sbctl verify` but aren't used for booting.

**Usage:**
```bash
sudo ./scripts/cleanup-legacy-boot.sh
```

**Safety:** Creates a timestamped backup before deletion. Restore with:
```bash
sudo mv /boot/EFI/backup-YYYYMMDD-HHMMSS/nixos /boot/EFI/nixos
```

## Running Scripts

All scripts should be run from the dotfiles repository root:

```bash
cd ~/dotfiles
sudo ./scripts/script-name.sh
```

## Permissions

- `nix-cleaner.sh`: No sudo required (operates on user's Nix profile)
- `setup-secure-boot.sh`: Requires sudo (manages system configuration and firmware)
- `cleanup-legacy-boot.sh`: Requires sudo (modifies `/boot/EFI` directory)

