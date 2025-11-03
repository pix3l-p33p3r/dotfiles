{ config, pkgs, ... }:

{
  # ───── Updates & maintenance ─────
  
  # Automatically update the NixOS system configuration
  # Disabled to improve boot time - use manual 'upgrade' alias instead
  system.autoUpgrade = {
    enable = false; # Disabled to improve boot time (was taking 12+ seconds)
    allowReboot = false; # Do NOT automatically reboot the system after an upgrade
    flake = "/home/pixel-peeper/dotfiles#alucard"; # Specify the Flake to use for the upgrade
    dates = "03:00"; # Run at 3 AM when enabled (not at boot)
  };

  # Garbage Collection settings for the Nix Store
  nix.gc = {
    automatic = true; # Enable automatic Garbage Collection
    dates = "Sun 03:00"; # Run GC every Sunday at 3 AM (not at boot)
    persistent = false; # Don't run missed GC at boot
    randomizedDelaySec = "1h"; # Randomize start time by up to 1 hour

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

