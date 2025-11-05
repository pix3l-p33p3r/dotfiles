{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../variables.nix { inherit pkgs inputs wallpaper; };
in
{
  imports = [
    ./hyprpanel.nix
    ./rofi.nix
    # ./hyprlauncher.nix # in the future maybe 
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];
}
