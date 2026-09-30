{ config, pkgs, ... }:

{
  # ───── Firefox ─────
  programs.firefox.enable = true;

  # Phone link (firewall TCP/UDP 1714-1764). Daemon is the HM user service
  # in configs/desktop/hyprland/core/services-config.nix.
  programs.kdeconnect.enable = true;

  # NetworkManager UI + secret agent: Home Manager enables services.network-manager-applet
  # for pixel-peeper. NixOS programs.nm-applet would spawn a second nm-applet.
}
