# NixOS configuration for pixel-peeper machine
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
      ./graphics.nix
      ./audio.nix
      ./bluetooth.nix
      
      # Display system
      ./x11.nix
      ./wayland.nix
      ./security.nix
      
      # Containerization & Virtualization
      ./docker.nix
      ./virt.nix
      
      # Maintenance
      ./maint.nix
    ];
}
