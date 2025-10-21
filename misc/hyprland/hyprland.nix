{ pkgs, inputs, ... }:
let
  variables = import ./variables.nix { inherit pkgs inputs; };
  submapsConfig = import ./submaps.nix { inherit variables; };
  keybindings = import ./keybindings.nix { inherit variables; };
  settings = import ./settings.nix { inherit variables keybindings; };
  servicesConfig = import ./services-config.nix { inherit variables; };
  hyprlockConfig = import ./hyprlock.nix { inherit pkgs; };
in
{
  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.extraConfig = submapsConfig;

  wayland.windowManager.hyprland.settings = settings;
} // servicesConfig // hyprlockConfig
