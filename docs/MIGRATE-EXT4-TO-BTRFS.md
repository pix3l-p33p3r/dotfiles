# Migrate ext4 → Btrfs (In-Place)

Non-destructive conversion from ext4 to Btrfs with subvolumes. Uses `btrfs-convert` which keeps an ext4 rollback image.

**Important:** Always backup critical data before starting. Applies to NVMe root (adjust device names as needed).

## Pre-flight

- Confirm NVMe health
- Ensure zram swap configured (already done in this repo)
- Backup critical data

## Steps

### 1) Boot NixOS Live ISO

```bash
lsblk -f  # Identify root partition (assumed /dev/nvme0n1p3)
```

### 2) Convert ext4 → Btrfs

```bash
sudo e2fsck -f /dev/nvme0n1p3
sudo btrfs-convert /dev/nvme0n1p3
```

Note: `btrfs-convert` creates `ext2_saved` subvolume for rollback.

### 3) Create Subvolumes

```bash
sudo mount -o subvolid=5 /dev/nvme0n1p3 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@var_log
sudo btrfs subvolume create /mnt/@snapshots
```

### 4) Move Data to Subvolumes

```bash
sudo mount -o subvol=@ /dev/nvme0n1p3 /mnt/newroot
sudo rsync -aHAX --info=progress2 /mnt/ /mnt/newroot/ \
  --exclude=@ --exclude=@home --exclude=@nix --exclude=@var_log --exclude=@snapshots

sudo mkdir -p /mnt/newroot/{home,nix,var/log,.snapshots}
sudo mount -o subvol=@home      /dev/nvme0n1p3 /mnt/newroot/home
sudo mount -o subvol=@nix       /dev/nvme0n1p3 /mnt/newroot/nix
sudo mount -o subvol=@var_log   /dev/nvme0n1p3 /mnt/newroot/var/log
sudo mount -o subvol=@snapshots /dev/nvme0n1p3 /mnt/newroot/.snapshots
```

### 5) Update NixOS Configuration

Edit `hardware-configuration.nix`:

```nix
let
  btrfsCommon = [
    "compress-force=zstd:3" "ssd" "noatime"
    "space_cache=v2" "autodefrag" "discard=async"
  ];
in {
  fileSystems."/" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = btrfsCommon ++ [ "subvol=@" ];
  };
  fileSystems."/home" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = btrfsCommon ++ [ "subvol=@home" ];
  };
  fileSystems."/nix" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = btrfsCommon ++ [ "subvol=@nix" ];
  };
  fileSystems."/var/log" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = btrfsCommon ++ [ "subvol=@var_log" ];
  };
  fileSystems."/.snapshots" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = btrfsCommon ++ [ "subvol=@snapshots" ];
  };
  services.fstrim.enable = true;
}
```

**Optional:** Disable CoW on `/nix` for speed (trade-off: less data safety):
```bash
sudo chattr +C /mnt/newroot/nix
```

### 6) Rebuild from Live Environment

```bash
sudo mount --rbind /dev  /mnt/newroot/dev
sudo mount --rbind /proc /mnt/newroot/proc
sudo mount --rbind /sys  /mnt/newroot/sys

sudo chroot /mnt/newroot /bin/sh -c \
  'nixos-rebuild switch --flake /home/pixel-peeper/dotfiles#alucard'

sudo reboot
```

### 7) Verify & Cleanup

```bash
findmnt -t btrfs
btrfs subvolume list /
```

When stable (after several days), drop ext4 rollback to reclaim space:
```bash
sudo btrfs-convert -i /dev/nvme0n1p3  # Removes ext2_saved
```

**Warning:** Only do this when you're certain you won't need to roll back.

## Rollback (If Needed)

From live ISO:
```bash
sudo mount -o subvolid=5 /dev/nvme0n1p3 /mnt
sudo btrfs subvolume list /mnt | less  # Find ext2_saved
# Mount ext2_saved to recover files or revert (advanced)
```

## Maintenance

- **Monthly scrub:** `sudo btrfs scrub start -Bd /`
- **Balance (when fragmented):** `sudo btrfs balance start -dusage=75 -musage=75 /`
- **TRIM:** Already enabled via `services.fstrim.enable = true`

## Notes

- Compression `zstd:3` balances speed/ratio for NVMe
- `discard=async` safe on modern kernels
- System tuned for low swap usage (zram, low swappiness)

---

**See Also:**
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md#filesystem-ext4-vs-btrfs) - Filesystem decision rationale
- [scripts/migrate-ext4-to-btrfs.sh](../scripts/migrate-ext4-to-btrfs.sh) - Automated script (use with caution)

