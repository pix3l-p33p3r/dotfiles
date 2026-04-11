{ config, pkgs, lib, ... }:

{
  networking.hostName = "alucard";

  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  nixpkgs.config.allowUnfree = true;

  # Do not change after initial install — controls stateful data locations.
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 1401946112; # 1337MB
  # Trust the main user so client-specified caches aren't ignored.
  nix.settings.trusted-users = [ "root" "pixel-peeper" ];

  nix.settings.max-jobs = "auto";
  nix.settings.cores = 0;
  nix.settings.auto-optimise-store = true;

  # Give up on a slow/offline substituter quickly so builds don't stall.
  nix.settings.connect-timeout = 5;

  # Build jobs run at lower priority to keep the desktop responsive.
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass   = "idle";

  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://catppuccin.cachix.org"
    "https://nix-community.cachix.org"  # home-manager, sops-nix
    "https://lanzaboote.cachix.org"
    "https://zen-browser.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
    "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
  ];

  # Required for the MCP-NixOS server and other dynamically linked binaries.
  programs.nix-ld.enable = true;

  # wsdd: needed by GVFS for WS-Discovery; silences gvfsd-wsdd warnings.
  environment.systemPackages = [ pkgs.wsdd ];

  networking.networkmanager.enable = true;
  # Prevent rebuilds and boots from stalling while waiting for a connection.
  systemd.services.NetworkManager-wait-online.enable = false;

  boot.kernel.sysctl = {
    "vm.swappiness" = 60;  # zram is fast compressed RAM — use it aggressively before OOM-killing
    "vm.vfs_cache_pressure" = 50;
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  # Weekly TRIM for SSD health.
  services.fstrim.enable = true;
}
