{ config, pkgs, ... }:

{
  # ───── System Packages ─────
  environment.systemPackages = with pkgs; [
    neovim
    home-manager
  ];

  # ───── Firefox ─────
  programs.firefox.enable = true;

  # ───── Network Manager Applet ─────
  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}

