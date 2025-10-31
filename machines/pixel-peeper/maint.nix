{ config, pkgs, ... }:

{
  # ───── Updates & maintenance ─────
  
  # Automatically update the NixOS system configuration
  system.autoUpgrade = {
    enable = true; # Enable automatic system upgrades
    allowReboot = false; # Do NOT automatically reboot the system after an upgrade
    flake = "/home/pixel-peeper/wow#nixos"; # Specify the Flake to use for the upgrade
    dates = "daily"; # Run the automatic upgrade process daily
  };

  # Garbage Collection settings for the Nix Store
  nix.gc = {
    automatic = true; # Enable automatic Garbage Collection
    dates = "weekly"; # Run GC weekly

    # Options passed to the 'nix store gc' command. Deletes old generations/files
    # that haven't been referenced for more than 20 days.
    options = "--delete-older-than 20d"; 
  };

  # Optimization of the Nix store
  nix.optimise = {
    automatic = true; # Enable automatic optimization

    # Optimization performs hard-linking of identical files in the Nix store 
    # to save disk space.
    dates = ["weekly"]; # Run optimization weekly
  };
}

