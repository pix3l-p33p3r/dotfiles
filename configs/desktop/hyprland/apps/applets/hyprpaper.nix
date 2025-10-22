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
}
