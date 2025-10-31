{ config, pkgs, ... }:

{
  # ───── Wayland Compositor ─────
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-hyprland 
      xdg-desktop-portal-gtk
    ];
  };
}

