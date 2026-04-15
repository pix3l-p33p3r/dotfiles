{ config, pkgs, ... }:
let
  primaryUser = "pixel-peeper";
in
{
  # ───── Updates & maintenance ─────
  
  # Automatically update the NixOS system configuration
  # Disabled to improve boot time - use manual 'upgrade' alias instead
  system.autoUpgrade = {
    enable = false; # Disabled to improve boot time (was taking 12+ seconds)
    allowReboot = false; # Do NOT automatically reboot the system after an upgrade
    flake = "${config.users.users.${primaryUser}.home}/dotfiles#alucard";
    dates = "03:00"; # Run at 3 AM when enabled (not at boot)
  };

  # Garbage Collection settings for the Nix Store
  nix.gc = {
    automatic = true; # Enable automatic Garbage Collection
    dates = "Sun 03:00"; # Run GC every Sunday at 3 AM (not at boot)
    persistent = true; # Run missed GC at next boot if the scheduled window was skipped
    randomizedDelaySec = "1h"; # Randomize start time by up to 1 hour

    # Options passed to the 'nix store gc' command. Deletes old generations/files
    # that haven't been referenced for more than 20 days.
    options = "--delete-older-than 20d"; 
  };

  # nix.settings.auto-optimise-store in system.nix already hard-links identical
  # files after every build. A separate weekly nix.optimise job would be redundant.

  # ───── /tmp hygiene ─────
  # systemd-tmpfiles-clean was taking ~12s on last boot because it had to stat
  # ~1.3GB of files in /tmp. Root causes identified:
  #
  #   /tmp/flake-archive  — 965MB leftover nix store written by 'nix flake archive'.
  #                         Not cleaned automatically; grows unbounded across reboots.
  #   /tmp/agkozak_zsh_prompt_*  — zero-byte lock files left per shell session by
  #                         the agkozak zsh prompt plugin; accumulates over time.
  #
  # 'e' type: adjusts existing paths without creating them; removes contents (like D)
  # if the path's modification time is older than the age argument.
  systemd.tmpfiles.rules = [
    "e /tmp/flake-archive            - - - 1d -"
    "e /tmp/agkozak_zsh_prompt_*     - - - 1d -"
  ];
}

