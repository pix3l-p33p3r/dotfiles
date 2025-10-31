{ config, pkgs, ... }:

{
  # ───── Bootloader configuration ─────
  boot.loader.systemd-boot.enable = true;
  
  # Limit the number of generations (old configs) shown in the boot menu.
  boot.loader.systemd-boot.configurationLimit = 7; 
  
  # Allows NixOS to manage EFI variables, necessary for systemd-boot to work.
  boot.loader.efi.canTouchEfiVariables = true;
}

