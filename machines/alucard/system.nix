{ config, pkgs, lib, ... }:

{
  networking.hostName = "alucard";

  # ───── Catppuccin Theme (NixOS-level) ─────
  # Global theme configuration for system-level components
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";
  
  # ───── Allow unfree packages ─────
  nixpkgs.config.allowUnfree = true;

  # ───── System State Version ─────
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";

  # ───── Flakes & Nix settings ─────
  # Enable flakes and the new command-line tools
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 1401946112; # 1337MB
  # Trust the main user so client-specified caches aren't ignored
  nix.settings.trusted-users = [ "root" "pixel-peeper" ];
  
  # Build optimization
  nix.settings.max-jobs = "auto"; # Use all available cores
  nix.settings.cores = 0; # 0 = use all available cores per job
  nix.settings.auto-optimise-store = true; # Automatically deduplicate store

  # Give up on a substituter quickly so a slow/offline cache doesn't stall builds
  nix.settings.connect-timeout = 5;

  # Daemon scheduling — build jobs run at lower priority so the desktop
  # stays responsive during a rebuild
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass   = "idle";

  # System-wide binary caches
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://catppuccin.cachix.org"
    "https://nix-community.cachix.org"  # home-manager, sops-nix, and other nix-community projects
    "https://lanzaboote.cachix.org"     # lanzaboote pre-built binaries
    "https://zen-browser.cachix.org"    # zen-browser pre-built binaries
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSHY="
    "lanzaboote.cachix.org-1:Nt9//zGmqkg67P7J4HZE5fJz6rKQX8a7YlBTHEPD0c="
    "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
  ];

  # ───── nix-ld ─────
  # Enable nix-ld for compatibility with dynamically linked executables (required for MCP-NixOS server)
  programs.nix-ld.enable = true;

  # wsdd: GVFS / network shares use this for WS-Discovery; silences gvfsd-wsdd "Failed to spawn wsdd"
  environment.systemPackages = [ pkgs.wsdd ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Disable wait-online so rebuilds and boots don't stall waiting for a network connection.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Reduce swapping aggressiveness
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Proactive OOM killer to reduce heavy swapping
  systemd.oomd.enable = true;

  # ───── Filesystem Maintenance ─────
  # Weekly TRIM for ext4 (helps maintain SSD performance)
  services.fstrim.enable = true;

}

