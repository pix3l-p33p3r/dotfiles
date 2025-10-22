{ pkgs, inputs, wallpaper, ... }:
let
  variables = import ./variables.nix { inherit pkgs inputs wallpaper; };
  submapsConfig = import ./submaps.nix { inherit variables; };
  keybindings = import ./keybindings.nix { inherit variables; };
  settings = import ./settings.nix { inherit variables keybindings; };
  servicesConfig = import ./services-config.nix { inherit variables; };
<<<<<<< HEAD
  hypridleConfig = import ./hypridle.nix { inherit variables lib; };
  hyprlockConfig = import ./hyprlock.nix { inherit pkgs; };
=======
  hyprlockConfig = import ./hyprlock.nix { inherit pkgs variables; };
>>>>>>> 84798cdf678c72f09e8db6c6ed90b09886eec420
in
{
  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.extraConfig = submapsConfig;

  wayland.windowManager.hyprland.settings = settings;
} // servicesConfig // hypridleConfig // hyprlockConfig
