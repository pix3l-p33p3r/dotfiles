{ config, pkgs, ... }:

{
  # ───── Security & PAM ─────
  security.pam.services.hyprlock = {};

  # ───── DCONF & GSETTINGS ─────
  programs.dconf.enable = true;
  services.dbus.enable = true;
}

