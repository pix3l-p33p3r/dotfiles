{ config, pkgs, ... }:

{
  # ───── Firefox ─────
  programs.firefox.enable = true;

  # ───── Network Manager Applet ─────
  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
