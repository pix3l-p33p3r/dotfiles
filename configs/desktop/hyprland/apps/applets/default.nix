{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../variables.nix { inherit pkgs inputs wallpaper; };
in
{
  imports = [
    # ./hyprpanel.nix
    ./wofi.nix
    ./hyprlauncher.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];
}
