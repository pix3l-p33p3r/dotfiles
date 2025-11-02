{ config, pkgs, lib, ... }:

{
  # ───── Zram Swap ─────
  # Disable stale disk swap and use compressed RAM swap
  swapDevices = lib.mkForce [];
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;  # Use 25% of RAM for zram swap
}

