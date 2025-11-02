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
}

