# Scripts

Utility scripts for managing NixOS dotfiles.

## Available Scripts

### `nix-cleaner.sh`

Cleans up old NixOS generations and frees disk space.

**Usage:**
```bash
./scripts/nix-cleaner.sh
```

Removes:
- Old system generations (keeps last 3)
- Old boot entries
- Garbage collection

### `setup-secure-boot.sh`

Automates Secure Boot setup with Lanzaboote.

**Usage:**
```bash
sudo ./scripts/setup-secure-boot.sh
```

Steps:
1. Enables Lanzaboote in configuration
2. Rebuilds system
3. Creates and enrolls Secure Boot keys
4. Rebuilds again for signed UKIs

**Run before enabling Secure Boot in firmware.**

### `cleanup-legacy-boot.sh`

Removes legacy boot entries from `/boot/EFI/nixos/`.

**Usage:**
```bash
sudo ./scripts/cleanup-legacy-boot.sh
```

Needed when migrating from systemd-boot to Lanzaboote. Creates timestamped backup before deletion.

## Running Scripts

Run from dotfiles repository root:

```bash
cd ~/dotfiles
sudo ./scripts/script-name.sh
```
