{ pkgs, inputs, wallpaper, ... }:

let
  # Copy wallpaper to Nix store so hyprlock can access it at runtime
  wallpaperPath = "${pkgs.copyPathToStore wallpaper}";
  # Copy avatar to Nix store so hyprlock can access it at runtime
  avatarPath = "${pkgs.copyPathToStore (inputs.self + "/assets/avatar/ryuma.png")}";
  
  # Read the template config file and substitute placeholders with actual paths
  configTemplate = builtins.readFile (./hyprlock.conf);
  configContent = builtins.replaceStrings
    [ "@WALLPAPER_PATH@" "@AVATAR_PATH@" ]
    [ wallpaperPath avatarPath ]
    configTemplate;
  
  # Read the mocha.conf color definitions file
  mochaConf = builtins.readFile (../../core/mocha.conf);
in
{
  # Official Catppuccin Mocha color definitions
  # This file is sourced by hyprlock.conf and can be used by other hyprland configs
  xdg.configFile."hypr/mocha.conf" = {
    text = mochaConf;
    force = true;
  };

  # Hyprlock only loads ~/.config/hypr/hyprlock.conf (Hyprutils::Path::findConfig), not hyprlock/hyprlock.conf.
  # Template: @WALLPAPER_PATH@ and @AVATAR_PATH@ substituted above.
  xdg.configFile."hypr/hyprlock.conf" = {
    text = configContent;
    force = true;
  };

  # Stylix can merge programs.hyprlock.settings into the same path; keep declarative lock config only.
  programs.hyprlock.enable = false;
}


