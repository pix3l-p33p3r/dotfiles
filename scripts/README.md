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

### `migrate-ext4-to-btrfs.sh`

Automates the in-place migration from ext4 to Btrfs filesystem:
1. Unlocks LUKS encrypted device
2. Converts ext4 to Btrfs (non-destructive)
3. Creates subvolumes (@, @home, @nix, @var_log, @snapshots)
4. Moves data to subvolumes
5. Rebuilds NixOS configuration

**Usage:**
```bash
# From NixOS live ISO:
sudo ./scripts/migrate-ext4-to-btrfs.sh

# With custom settings:
sudo ROOT_PARTITION=/dev/nvme0n1p3 LUKS_UUID=your-uuid ./scripts/migrate-ext4-to-btrfs.sh
```

**Important:** 
- Run this from a NixOS live ISO (same or newer than your system)
- Backup critical data before starting
- Your ext4 filesystem is preserved as `ext2_saved` for rollback
- The migration is non-destructive but requires careful execution

**See:** `MIGRATE-EXT4-TO-BTRFS.md` for detailed documentation and manual steps.

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

