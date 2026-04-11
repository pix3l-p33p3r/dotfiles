{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../../core/variables.nix { inherit pkgs inputs wallpaper; };
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${variables.wallpaper}"
      ];
      wallpaper = [
        ",${variables.wallpaper}"
      ];
      splash = true;
    };
  };

  # Hyprland's compositor socket isn't fully ready the instant graphical-session.target
  # fires. Without this delay hyprpaper connects too early, finds no wallpaper target,
  # and the monitor stays black. 2s matches the hyprpanel delay for the same reason.
  systemd.user.services.hyprpaper.Service.ExecStartPre =
    "${pkgs.coreutils}/bin/sleep 2";
}
