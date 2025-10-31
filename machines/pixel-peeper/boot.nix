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

  # sbctl is provided via machines/pixel-peeper/programs.nix systemPackages
  # Use sbctl for key management and UKI signing

  # Where sbctl will store and read your PK/KEK/db bundle
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";
}

