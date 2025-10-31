{ config, pkgs, ... }:

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
  nix.settings.download-buffer-size = 104857600; # 100MB

  # Enable networking
  networking.networkmanager.enable = true;

  # ───── Hostname ─────
  networking.hostName = "pixel-peeper";

  # ───── OpenSSH ─────
  services.openssh.enable = true;

  # ───── CUPS ─────
  services.printing.enable = true;
}

