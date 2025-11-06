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
5. Optionally sets up encrypted /data partition on nvme0n1p3 (separate LUKS password)
6. Rebuilds NixOS configuration

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
- `/data` partition uses separate LUKS password (you'll be prompted for both at boot)

**See:** `MIGRATE-EXT4-TO-BTRFS.md` for detailed documentation and manual steps.

### `backup-before-migration.sh`

Creates a backup of critical and important files before migration:
- **Critical**: SSH keys, GPG keys, Taskwarrior/Timewarrior data, JoplinBackup
- **Important** (full mode): Documents, Pictures, Videos, Music, Downloads, configs

**Usage:**
```bash
# Minimal backup (critical files only, ~50-100MB):
./scripts/backup-before-migration.sh

# Full backup (includes personal files, ~5-10GB):
BACKUP_MODE=full ./scripts/backup-before-migration.sh

# Custom destination:
BACKUP_DEST=/path/to/external/drive ./scripts/backup-before-migration.sh
```

**Important:** 
- Run this BEFORE migration
- Copy backup to external storage (USB drive, cloud, etc.)
- Backup is stored in `~/backup-pre-migration-TIMESTAMP/`

## Running Scripts

All scripts should be run from the dotfiles repository root:

```bash
cd ~/dotfiles
sudo ./scripts/script-name.sh
```

## Permissions

- `nix-cleaner.sh`: No sudo required (operates on user's Nix profile)
- `backup-before-migration.sh`: No sudo required (creates user backups)
- `setup-secure-boot.sh`: Requires sudo (manages system configuration and firmware)
- `cleanup-legacy-boot.sh`: Requires sudo (modifies `/boot/EFI` directory)
- `migrate-ext4-to-btrfs.sh`: Requires sudo (filesystem migration, run from live ISO)

