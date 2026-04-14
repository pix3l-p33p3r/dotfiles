{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../../core/variables.nix { inherit pkgs inputs wallpaper; };
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${variables.wallpaper}" ];
      # Attrset form (home-manager → hyprpaper.conf): empty monitor = all outputs.
      wallpaper = [
        {
          monitor = "";
          path = "${variables.wallpaper}";
        }
      ];
      splash = false;
    };
  };

  # Hyprland's compositor socket isn't fully ready the instant graphical-session.target
  # fires. Without this delay hyprpaper connects too early, finds no wallpaper target,
  # and the monitor stays black.
  systemd.user.services.hyprpaper.Service.ExecStartPre =
    "${pkgs.coreutils}/bin/sleep 3";
}
