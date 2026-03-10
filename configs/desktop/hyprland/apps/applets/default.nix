{ pkgs, inputs, config, wallpaper, ... }:
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
