{ config, pkgs, lib, ... }:

{
  # ───── Bootloader configuration ─────
  # Lanzaboote provides an external installer; disable systemd-boot module
  boot.loader.systemd-boot.enable = lib.mkForce false;
  
  # Allows NixOS to manage EFI variables, necessary for systemd-boot to work.
  boot.loader.efi.canTouchEfiVariables = true;

  # ───── Lanzaboote (Secure Boot with UKI) ─────
  # Builds signed Unified Kernel Images and integrates with systemd-boot.
  boot.lanzaboote.enable = true;

  # sbctl is provided via machines/alucard/programs.nix systemPackages
  # Use sbctl for key management and UKI signing

  # Where sbctl will store and read your PK/KEK/db bundle
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  # ───── Firmware updates with fwupd ─────
  
  # Enable fwupd for firmware updates (BIOS, EC, ME, etc.)
  services.fwupd.enable = true;

  # Install firmware packages for Intel microcode
  hardware.enableRedistributableFirmware = true;

  # ───── Boot Performance Optimizations ─────
  
  # Silent boot for faster startup
  boot.kernelParams = [
    "quiet"           # Reduce boot messages
    "loglevel=3"      # Show only errors
    "systemd.show_status=auto"  # Auto-hide systemd status
    "rd.udev.log_level=3"       # Reduce udev verbosity
  ];
  
  # Faster boot timeout
  boot.loader.timeout = 1;  # 1 second bootloader menu (was default 5)
  
  # Enable parallel service startup
  systemd.services = {
    # Delay non-critical firmware updates to after boot
    fwupd.wantedBy = lib.mkForce [];
    fwupd-refresh.wantedBy = lib.mkForce [];
  };
}

