{ pkgs, lib, inputs, wallpaper, ... }:
let
  variables = import ./variables.nix { inherit pkgs inputs wallpaper; };
  submapsConfig = import ./submaps.nix { inherit variables; };
  keybindings = import ./keybindings.nix { inherit variables; };
  settings = import ./settings.nix { inherit variables keybindings; };
in
{
  imports = [ ./services-config.nix ];

  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.extraConfig = submapsConfig;

  wayland.windowManager.hyprland.settings = settings;
}
