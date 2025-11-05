## Migrate ext4 → Btrfs (in-place, safe, and NixOS-friendly)

This guide converts an existing ext4 root to Btrfs without data loss using `btrfs-convert`, then sets up subvolumes, mounts, and NixOS options. It includes verification, rollback, and post-migration maintenance.

Applies to: NVMe root at `/dev/nvme0n1p3` (adjust if different), NixOS with flakes, Home Manager standalone, Hyprland desktop.

Important: Although `btrfs-convert` is non-destructive and keeps a rollback image, always back up critical data before starting.

---

### 0) Pre-flight

- Confirm NVMe health (already checked: healthy, 5% wear, 0 media errors).
- Ensure zram swap and low swappiness are configured (this repo already does that).
- Backup critical data (e.g., secrets, irreplaceable files).

---

### 1) Identify partitions

Boot a NixOS live ISO (same or newer than your system), then:

```bash
lsblk -f
```

Identify your root partition (assumed `/dev/nvme0n1p3`). Replace device names below if different.

---

### 2) Convert ext4 → Btrfs (non-destructive)

Still in the live ISO:

```bash
sudo e2fsck -f /dev/nvme0n1p3
sudo btrfs-convert /dev/nvme0n1p3
```

Notes:
- `btrfs-convert` retains your ext4 as a snapshot-like image (`ext2_saved`) so you can roll back.
- Do NOT skip `e2fsck`.

---

### 3) Create subvolumes

Mount the top-level (ID 5) and create subvolumes for a clean layout:

```bash
sudo mount -o subvolid=5 /dev/nvme0n1p3 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@var_log
sudo btrfs subvolume create /mnt/@snapshots
```

---

### 4) Move data into subvolumes

Mount `@` as new root, then copy data from the top-level into it (excluding the subvols you just created):

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

Verify that `/mnt/newroot` looks like a sane root filesystem with expected content in `/home`, `/nix`, `/var/log`.

---

### 5) Update NixOS mounts

Edit your system’s `hardware-configuration.nix` or equivalent module to set Btrfs + subvolumes.

Recommended mount options (NVMe desktop):

```nix
let
  btrfsCommon = [
    "compress-force=zstd:3"
    "ssd"
    "noatime"
    "space_cache=v2"
    "autodefrag"
    "discard=async"
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

  # Optional: weekly TRIM (ext4 or btrfs)
  services.fstrim.enable = true;
}
```

Tip: If you want maximum `/nix` speed, you can choose to disable CoW on `/nix` after mounting (trade-off: slightly less data safety for `/nix` store, which is reproducible anyway):

```bash
sudo chattr +C /mnt/newroot/nix
```

Then rebuild indexes with a `nix` GC if needed later. Most users can keep `/nix` compressed just fine.

---

### 6) Rebuild from the live environment

Bind-mount system dirs and enter your system to rebuild using your flake:

```bash
sudo mount --rbind /dev  /mnt/newroot/dev
sudo mount --rbind /proc /mnt/newroot/proc
sudo mount --rbind /sys  /mnt/newroot/sys

sudo chroot /mnt/newroot /bin/sh -c \
  'nixos-rebuild switch --flake /home/pixel-peeper/dotfiles#alucard'
```

If you prefer `nixos-enter` instead of manual bind mounts:

```bash
sudo nixos-enter --root /mnt/newroot -- \
  nixos-rebuild switch --flake /home/pixel-peeper/dotfiles#alucard
```

Reboot into your Btrfs system:

```bash
sudo reboot
```

---

### 7) Verify and clean up

Once booted, verify mounts:

```bash
findmnt -t btrfs
btrfs subvolume list /
```

When you’re satisfied the system is stable for several days, drop the saved ext4 image to reclaim space:

```bash
sudo btrfs-convert -i /dev/nvme0n1p3
```

This removes the fallback ext4 image. Do not do this until you’re sure you won’t need to roll back.

---

### 8) Optional snapshots

Enable snapshots (choose one):

- Snapper (classic): timeline + pre/post hooks for `nixos-rebuild`.
- btrbk / btrfs-assistant: friendlier UIs and cron-like policies.

Example (snapper, conceptual):

```nix
{ config, ... }:
{
  services.snapper = {
    snapshotRootOnBoot = true;
    configs = {
      root = {
        subvolume = "/";
        timeline = true;
      };
      home = {
        subvolume = "/home";
        timeline = true;
      };
    };
  };
}
```

---

### 9) Maintenance

- Monthly scrub:

```bash
sudo btrfs scrub start -Bd /
```

- Occasional balance (when fragmented/low free chunks):

```bash
sudo btrfs balance start -dusage=75 -musage=75 /
```

- TRIM (if not using `discard=async` or in addition to it):

```nix
services.fstrim.enable = true;
```

---

### Rollback procedure (if something goes wrong)

From live ISO:

1) Mount top-level and list subvols:

```bash
sudo mount -o subvolid=5 /dev/nvme0n1p3 /mnt
sudo btrfs subvolume list /mnt | less
```

2) You can mount the `ext2_saved` to recover data or revert to the ext4 image (advanced):

```bash
sudo btrfs subvolume snapshot /mnt/ext2_saved /mnt/@rollback
```

Then mount `@rollback` as `/` temporarily to recover files. If you absolutely must return to ext4 entirely, consult `btrfs-convert` docs for full revert (rarely necessary if backups exist).

---

### Fresh install alternative (optional)

1) Repartition (keep same layout), format root as Btrfs.
2) Create subvols as above.
3) Mount subvols to target tree, restore `/home` from backup.
4) `nixos-install --flake /mnt/home/pixel-peeper/dotfiles#alucard`.

This yields the cleanest filesystem history but requires a proper backup/restore.

---

### Notes for this repo

- System is tuned for low swap usage (zram, low swappiness, systemd-oomd). Keep it—Btrfs benefits from less write pressure.
- Compression level `zstd:3` balances speed/ratio for NVMe. You can raise to `zstd:5` if CPU is plentiful and you want stronger compression.
- `discard=async` is safe on modern kernels; weekly `fstrim` is also enabled as an alternative/complement.

If you want me to execute the migration on this machine, say “Proceed” and I’ll run it step-by-step with you.



