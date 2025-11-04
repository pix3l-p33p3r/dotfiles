# NixOS configuration for alucard machine
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [
      # Hardware configuration (auto-generated)
      ./hardware-configuration.nix
      
      # Modular system configuration
      ./boot.nix
      ./system.nix
      ./locale.nix
      ./users.nix
      ./programs.nix
      
      # Hardware-specific
      ./hardware-acceleration.nix
      ./audio.nix
      ./bluetooth.nix
      ./power.nix
      ./swap.nix
      
      # Display system
      ./x11.nix
      ./wayland.nix
      ./security.nix
      ./secrets.nix
      
      # Containerization & Virtualization
      ./docker.nix
      ./virt.nix
      
      # Maintenance
      ./maint.nix
    ];
}
