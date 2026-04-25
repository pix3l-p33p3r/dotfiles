{ config, pkgs, ... }:

{
  # ───── Wayland Compositor ─────
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Thunar / GTK: trash, removable volumes, smb:// sftp:// and other GVfs locations.
  # (Home Manager's pkgs.gvfs alone does not set GIO_EXTRA_MODULES or D-Bus services.)
  services.gvfs.enable = true;

  # D-Bus thumbnailer used by Thunar (see configs/media/thunar.nix).
  services.tumbler.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-hyprland 
      xdg-desktop-portal-gtk
    ];
  };
}

