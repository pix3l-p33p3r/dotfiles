{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../variables.nix { inherit pkgs inputs wallpaper; };
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
}
