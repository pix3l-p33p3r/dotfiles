{ pkgs, inputs, config, wallpaper, ... }:
{
  imports = [
    ./hyprpanel.nix
    # ./wayle.nix  # Wayle replacement — uncomment to switch (in-progress)
    ./rofi.nix
    # ./hyprlauncher.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];
}
