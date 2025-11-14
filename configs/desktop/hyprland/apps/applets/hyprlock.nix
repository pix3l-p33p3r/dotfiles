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
in
{
  # Config file: ./hyprlock.conf (template with @WALLPAPER_PATH@ and @AVATAR_PATH@ placeholders)
  xdg.configFile."hyprlock/hyprlock.conf" = {
    text = configContent;
    force = true;
  };
}


