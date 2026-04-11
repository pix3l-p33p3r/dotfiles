{ config, pkgs, lib, ... }:

{
  # ───── Zram Swap ─────
  # Disable stale disk swap and use compressed RAM swap
  swapDevices = lib.mkForce [];
  zramSwap.enable = true;
  zramSwap.memoryPercent = 20;  # Use 20% of RAM for zram swap (~3.2GB on 16GB; zstd compresses 3-4x so effective headroom is larger)
}

