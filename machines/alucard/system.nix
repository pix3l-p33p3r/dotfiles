{ config, pkgs, lib, ... }:

{
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
  
  # System-wide binary caches
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://catppuccin.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
  ];

  # ───── nix-ld ─────
  # Enable nix-ld for compatibility with dynamically linked executables (required for MCP-NixOS server)
  programs.nix-ld.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Avoid long boot waits for network-online
  systemd.services."NetworkManager-wait-online".enable = false;

  # ───── Hostname ─────
  networking.hostName = "alucard";

  # ───── OpenSSH ─────
  services.openssh.enable = true;

  # ───── CUPS ─────
  services.printing.enable = true;
}

