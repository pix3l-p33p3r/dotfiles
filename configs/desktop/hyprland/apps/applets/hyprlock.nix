{ pkgs, inputs, wallpaper, ... }:

let
  # Copy paths to Nix store so hyprlock can access them at runtime
  # hyprlock needs actual file paths, not Nix path references
  wallpaperPath = "${pkgs.copyPathToStore wallpaper}";
  avatarPath = "${pkgs.copyPathToStore (inputs.self + "/assets/avatar/ryuma_pixel-peeper.png")}";
  
  # Read the template config file and substitute placeholders with actual paths
  configTemplate = builtins.readFile (./hyprlock.conf);
  configContent = builtins.replaceStrings
    [ "@WALLPAPER_PATH@" "@AVATAR_PATH@" ]
    [ wallpaperPath avatarPath ]
    configTemplate;
  
  # Read the mocha.conf color definitions file
  mochaConf = builtins.readFile (../core/mocha.conf);
in
{
  # Official Catppuccin Mocha color definitions
  # This file is sourced by hyprlock.conf and can be used by other hyprland configs
  xdg.configFile."hypr/mocha.conf" = {
    text = mochaConf;
    force = true;
  };

  # Config file: ./hyprlock.conf (template with @WALLPAPER_PATH@ and @AVATAR_PATH@ placeholders)
  xdg.configFile."hyprlock/hyprlock.conf" = {
    text = configContent;
    force = true;
  };
}


