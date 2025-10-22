{ pkgs, inputs, config, wallpaper, ... }:
let
  variables = import ../variables.nix { inherit pkgs inputs wallpaper; };
in
{
  imports = [
    ./hyprpanel.nix
    ./sway-notification-center.nix
    ./wofi.nix
    ./sherlock.nix
    ./hyprpaper.nix
  ];
}
