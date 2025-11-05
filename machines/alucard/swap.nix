{ config, pkgs, lib, ... }:

{
  # ───── Zram Swap ─────
  # Disable stale disk swap and use compressed RAM swap
  swapDevices = lib.mkForce [];
  zramSwap.enable = true;
  zramSwap.memoryPercent = 15;  # Use 15% of RAM for zram swap (less aggressive)
}

