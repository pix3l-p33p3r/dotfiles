{ config, pkgs, ... }:

{
  # ───── Firefox ─────
  programs.firefox.enable = true;

  # NetworkManager UI + secret agent: Home Manager enables services.network-manager-applet
  # for pixel-peeper. NixOS programs.nm-applet would spawn a second nm-applet.
}
