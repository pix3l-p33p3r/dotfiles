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

  # Pin the legacy hyprlang renderer. home-manager changed the default to
  # "lua" for new (stateVersion >= 26.05) configs; switching would require
  # rewriting submapsConfig / settings as Lua function calls. Explicit pin
  # silences the activation-time warning.
  wayland.windowManager.hyprland.configType = "hyprlang";

  wayland.windowManager.hyprland.extraConfig = submapsConfig;

  wayland.windowManager.hyprland.settings = settings;
}
